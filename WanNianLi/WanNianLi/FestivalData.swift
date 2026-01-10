//
//  FestivalData.swift
//  WanNianLi
//
//  Festival data for Chinese calendar with online update support
//

import Foundation

/// Festival data manager with online update support
class FestivalData: ObservableObject {
    
    static let shared = FestivalData()
    
    // MARK: - Festival Dictionaries
    
    @Published private(set) var solarFestivals: [String: String] = [:]
    @Published private(set) var lunarFestivals: [String: String] = [:]
    @Published private(set) var weekFestivals: [String: String] = [:]
    @Published private(set) var lastUpdateDate: Date?
    @Published var isLoading = false
    @Published var updateError: String?
    
    // Remote URL for festivals.js
    private let remoteURL = "https://raw.githubusercontent.com/zfdang/chinese-lunar-calendar-for-mac/master/WanNianLi/WanNianLi/Resources/vendors/festivals.js"
    
    // Local cache file
    private var cacheURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("WanNianLi", isDirectory: true)
        return appFolder.appendingPathComponent("festivals_cache.json")
    }
    
    // MARK: - Initialization
    
    init() {
        loadDefaultFestivals()
        loadCachedFestivals()
    }
    
    // MARK: - Default Festivals
    
    private func loadDefaultFestivals() {
        // Default solar festivals
        solarFestivals = [
            "0101": "元旦",
            "0214": "情人节",
            "0305": "学雷锋纪念日",
            "0308": "妇女节",
            "0312": "植树节",
            "0315": "消费者权益日",
            "0401": "愚人节",
            "0501": "劳动节",
            "0504": "青年节",
            "0508": "世界红十字日",
            "0601": "儿童节",
            "0626": "国际禁毒日",
            "0701": "中共诞辰 香港回归",
            "0707": "抗日战争纪念日",
            "0801": "建军节",
            "0815": "抗日战争胜利",
            "0910": "中国教师节",
            "1001": "国庆节",
            "1010": "辛亥革命纪念日",
            "1031": "万圣节",
            "1224": "平安夜",
            "1225": "圣诞节"
        ]
        
        // Default lunar festivals
        lunarFestivals = [
            "0101": "春节",
            "0115": "元宵节",
            "0505": "端午节",
            "0707": "七夕节",
            "0815": "中秋节",
            "0909": "重阳节",
            "1208": "腊八节",
            "0100": "除夕"
        ]
        
        // Default week-based festivals (format: MMWD - month, week, day)
        weekFestivals = [
            "0502": "母亲节",  // May, 2nd Sunday
            "0603": "父亲节",  // June, 3rd Sunday
            "1144": "感恩节"   // November, 4th Thursday
        ]
    }
    
    // MARK: - Cache Management
    
    private func loadCachedFestivals() {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: cacheURL)
            let cache = try JSONDecoder().decode(FestivalCache.self, from: data)
            solarFestivals = cache.solarFestivals
            lunarFestivals = cache.lunarFestivals
            weekFestivals = cache.weekFestivals
            lastUpdateDate = cache.updateDate
            print("Loaded festival cache from \(cacheURL.path)")
        } catch {
            print("Failed to load festival cache: \(error)")
        }
    }
    
    private func saveCacheToFile() {
        let cache = FestivalCache(
            solarFestivals: solarFestivals,
            lunarFestivals: lunarFestivals,
            weekFestivals: weekFestivals,
            updateDate: Date()
        )
        
        do {
            // Create directory if needed
            let directory = cacheURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            
            let data = try JSONEncoder().encode(cache)
            try data.write(to: cacheURL)
            lastUpdateDate = cache.updateDate
            print("Saved festival cache to \(cacheURL.path)")
        } catch {
            print("Failed to save festival cache: \(error)")
        }
    }
    
    // MARK: - Online Update
    
    func updateFromRemote() async {
        await MainActor.run {
            isLoading = true
            updateError = nil
        }
        
        do {
            guard let url = URL(string: remoteURL) else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let jsContent = String(data: data, encoding: .utf8) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            // Parse JavaScript content
            let (solar, lunar, week) = parseJavaScript(jsContent)
            
            await MainActor.run {
                if !solar.isEmpty { solarFestivals = solar }
                if !lunar.isEmpty { lunarFestivals = lunar }
                if !week.isEmpty { weekFestivals = week }
                saveCacheToFile()
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                updateError = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    // MARK: - JavaScript Parser
    
    private func parseJavaScript(_ content: String) -> ([String: String], [String: String], [String: String]) {
        var solar: [String: String] = [:]
        var lunar: [String: String] = [:]
        var week: [String: String] = [:]
        
        // Parse SOLARFESTIVAL
        if let range = content.range(of: "SOLARFESTIVAL\\s*=\\s*\\{([^}]+)\\}", options: .regularExpression) {
            let block = String(content[range])
            solar = parseKeyValuePairs(block)
        }
        
        // Parse LUNARFESTIVAL
        if let range = content.range(of: "LUNARFESTIVAL\\s*=\\s*\\{([^}]+)\\}", options: .regularExpression) {
            let block = String(content[range])
            lunar = parseKeyValuePairs(block)
        }
        
        // Parse OTHERFESTIVAL (week-based)
        if let range = content.range(of: "OTHERFESTIVAL\\s*=\\s*\\{([^}]+)\\}", options: .regularExpression) {
            let block = String(content[range])
            week = parseWeekFestivals(block)
        }
        
        return (solar, lunar, week)
    }
    
    private func parseKeyValuePairs(_ block: String) -> [String: String] {
        var result: [String: String] = [:]
        
        // Match: "MMDD": "Name" (not commented out)
        let pattern = #"^\s*"(\d{4})"\s*:\s*"([^"]+)""#
        
        for line in block.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") { continue }  // Skip comments
            
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                if let keyRange = Range(match.range(at: 1), in: line),
                   let valueRange = Range(match.range(at: 2), in: line) {
                    let key = String(line[keyRange])
                    let value = String(line[valueRange])
                    result[key] = value
                }
            }
        }
        
        return result
    }
    
    private func parseWeekFestivals(_ block: String) -> [String: String] {
        var result: [String: String] = [:]
        
        // Match: "MMWD": "Name" where W is week number, D is weekday (0-6)
        let pattern = #"^\s*"(\d{4})"\s*:\s*"([^"]+)""#
        
        for line in block.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") { continue }
            
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                if let keyRange = Range(match.range(at: 1), in: line),
                   let valueRange = Range(match.range(at: 2), in: line) {
                    let key = String(line[keyRange])
                    let value = String(line[valueRange])
                    result[key] = value
                }
            }
        }
        
        return result
    }
    
    // MARK: - Public Lookup Methods
    
    func solarFestival(month: Int, day: Int) -> String? {
        let key = String(format: "%02d%02d", month, day)
        return solarFestivals[key]
    }
    
    func lunarFestival(month: Int, day: Int, isLeapMonth: Bool) -> String? {
        if isLeapMonth { return nil }
        let key = String(format: "%02d%02d", month, day)
        return lunarFestivals[key]
    }
    
    /// Check for Chinese New Year's Eve
    func isChineseNewYearEve(lunarYear: Int, lunarMonth: Int, lunarDay: Int) -> Bool {
        if lunarMonth != 12 { return false }
        let lastDay = LunarCalendar.daysInMonth(year: lunarYear, month: 12)
        return lunarDay == lastDay
    }
    
    /// Get week-based festival
    /// Format in weekFestivals: MMWD where MM=month, W=week, D=weekday (0-6)
    func weekFestival(month: Int, weekOfMonth: Int, weekday: Int) -> String? {
        // Check for festivals like "0502" (May, 2nd week, Sunday=0)
        let key = String(format: "%02d%d%d", month, weekOfMonth, weekday)
        return weekFestivals[key]
    }
}

// MARK: - Cache Model

private struct FestivalCache: Codable {
    let solarFestivals: [String: String]
    let lunarFestivals: [String: String]
    let weekFestivals: [String: String]
    let updateDate: Date
}
