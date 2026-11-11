//
//  LevelData.swift
//  Braille_Read
//
//  Created by Oliver Park on 1/8/26.
//


import Foundation


enum BrailleType: String, CaseIterable {
    case jeongja
    case yakja

    var displayName: String {
        switch self {
        case .jeongja: return "Grade 1"
        case .yakja: return "Grade 2"
        }
    }

    var subtitle: String {
        switch self {
        case .jeongja: return "Standard Braille (정자)"
        case .yakja: return "Abbreviated Braille (약자)"
        }
    }
}


struct BrailleSection: Identifiable {
    let id = UUID()
    let title: String
    let levels: [BrailleLevel]
}

struct BrailleLevel: Identifiable, Hashable, Equatable{
    let id = UUID()
    let title: String
    let storageKey: String
    let letters: [BrailleLetter]
    let useLandscape: Bool
    
    init(title: String, storageKey: String, letters: [BrailleLetter], useLandscape: Bool = false) {
        self.title = title
        self.storageKey = storageKey
        self.letters = letters
        self.useLandscape = useLandscape
    }
}


struct BrailleLetter: Identifiable, Hashable, Equatable {
    let id = UUID()
    let hangul: String
    let englishName: String
    let cells: [Set<Int>]
    
    init(hangul: String, englishName: String, activeDots: Set<Int>) {
        self.hangul = hangul
        self.englishName = englishName
        self.cells = [activeDots]
    }

    init(hangul: String, englishName: String, cells: [Set<Int>]) {
        self.hangul = hangul
        self.englishName = englishName
        self.cells = cells
    }
}


struct BrailleData {
    static let sections: [BrailleSection] = [
        section1,
        section2,
        section3
    ]
    

    static let section1 = BrailleSection(
        title: "Section 1: Basics",
        levels: [
            BrailleLevel(
                title: "Level 1: Initial Consonants",
                storageKey: "level1_completed",
                letters: [
                    BrailleLetter(hangul: "ㄱ", englishName: "giyeok", activeDots: [4]),
                    BrailleLetter(hangul: "ㄴ", englishName: "nieun", activeDots: [1, 4]),
                    BrailleLetter(hangul: "ㄷ", englishName: "digeut", activeDots: [2, 4]),
                    BrailleLetter(hangul: "ㄹ", englishName: "rieul", activeDots: [5]),
                    BrailleLetter(hangul: "ㅁ", englishName: "mieum", activeDots: [1, 5]),
                    BrailleLetter(hangul: "ㅂ", englishName: "bieup", activeDots: [4, 5]),
                    BrailleLetter(hangul: "ㅅ", englishName: "siot", activeDots: [6]),
                    BrailleLetter(hangul: "ㅇ", englishName: "ieung", activeDots: []),
                    BrailleLetter(hangul: "ㅈ", englishName: "jieut", activeDots: [4, 6]),
                    BrailleLetter(hangul: "ㅊ", englishName: "chieut", activeDots: [5, 6]),
                    BrailleLetter(hangul: "ㅋ", englishName: "kieuk", activeDots: [1, 2, 4]),
                    BrailleLetter(hangul: "ㅌ", englishName: "tieut", activeDots: [1, 2, 5]),
                    BrailleLetter(hangul: "ㅍ", englishName: "pieup", activeDots: [1, 4, 5]),
                    BrailleLetter(hangul: "ㅎ", englishName: "hieut", activeDots: [2, 4, 5]),
                    BrailleLetter(hangul: "된소리", englishName: "Period", activeDots: [6])
                ],
                useLandscape: false
            ),
            BrailleLevel(
                title: "Level 2: Vowels 1 (Basic)",
                storageKey: "level2_completed",
                letters: [
                    BrailleLetter(hangul: "ㅏ", englishName: "a", activeDots: [1, 2, 6]),
                    BrailleLetter(hangul: "ㅑ", englishName: "ya", activeDots: [3, 4, 5]),
                    BrailleLetter(hangul: "ㅓ", englishName: "eo", activeDots: [2, 3, 4]),
                    BrailleLetter(hangul: "ㅕ", englishName: "yeo", activeDots: [1, 5, 6]),
                    BrailleLetter(hangul: "ㅗ", englishName: "o", activeDots: [1, 3, 6]),
                    BrailleLetter(hangul: "ㅛ", englishName: "yo", activeDots: [3, 4, 6]),
                    BrailleLetter(hangul: "ㅜ", englishName: "u", activeDots: [1, 3, 4]),
                    BrailleLetter(hangul: "ㅠ", englishName: "yu", activeDots: [1, 4, 6]),
                    BrailleLetter(hangul: "ㅡ", englishName: "eu", activeDots: [2, 4, 6]),
                    BrailleLetter(hangul: "ㅣ", englishName: "i", activeDots: [1, 3, 5]),
                    BrailleLetter(hangul: "ㅔ", englishName: "e", activeDots: [1, 3, 4, 5]),
                    BrailleLetter(hangul: "ㅐ", englishName: "ae", activeDots: [1, 2, 3, 5])
                ],
                useLandscape: false
            ),
          
            BrailleLevel(
                title: "Level 3: Vowels 2 (Complex)",
                storageKey: "level4_completed",
                letters: [
                    BrailleLetter(hangul: "ㅔ", englishName: "e", activeDots: [1, 3, 4, 5]),
                    BrailleLetter(hangul: "ㅐ", englishName: "ae", activeDots: [1, 2, 3, 5]),
                    BrailleLetter(hangul: "ㅖ", englishName: "ye", cells: [[3, 4], [1, 3, 4, 5]]),
                    BrailleLetter(hangul: "ㅒ", englishName: "yae", cells: [[3, 4, 5], [1, 2, 3, 5]]),
                    BrailleLetter(hangul: "ㅘ", englishName: "wa", cells: [[1, 2, 3, 6], [1, 2, 3, 5]]),
                    BrailleLetter(hangul: "ㅙ", englishName: "wae", cells: [[1, 2, 3, 6], [1, 2, 3, 5]]),
                    BrailleLetter(hangul: "ㅚ", englishName: "oe", cells: [[1, 3, 4, 5, 6]]),
                    BrailleLetter(hangul: "ㅝ", englishName: "wo", cells: [[1, 3, 4, 5, 6], [2, 3, 4]]),
                    BrailleLetter(hangul: "ㅞ", englishName: "we", cells: [[1, 3, 4, 5, 6], [1, 3, 4, 5]]),
                    BrailleLetter(hangul: "ㅟ", englishName: "wi", cells: [[1, 3, 4, 5, 6], [1, 2, 3, 5]]),
                    BrailleLetter(hangul: "ㅢ", englishName: "ui", cells: [[2, 4, 6], [1, 3, 5]])
                ],
                useLandscape: true
            )
        ]
    )
    
    // MARK: Section 2
    static let section2 = BrailleSection(
        title: "Section 2: Syllables",
        levels: [
          
            BrailleLevel(
                title: "Level 1: 가나다 (Basic Syllables)",
                storageKey: "sec2_lvl1_completed",
                letters: [
                    BrailleLetter(hangul: "가", englishName: "Ga", cells: [[4], [1, 2, 6]]),
                    BrailleLetter(hangul: "나", englishName: "Na", cells: [[1, 4], [1, 2, 6]]),
                    BrailleLetter(hangul: "다", englishName: "Da", cells: [[2, 4], [1, 2, 6]]),
                    BrailleLetter(hangul: "라", englishName: "Ra", cells: [[5], [1, 2, 6]]),
                    BrailleLetter(hangul: "마", englishName: "Ma", cells: [[1, 5], [1, 2, 6]]),
                    BrailleLetter(hangul: "바", englishName: "Ba", cells: [[4, 5], [1, 2, 6]]),
                    BrailleLetter(hangul: "사", englishName: "Sa", cells: [[6], [1, 2, 6]]),
                    BrailleLetter(hangul: "아", englishName: "Ah", cells: [[1, 2, 6]]),
                    BrailleLetter(hangul: "자", englishName: "Ja", cells: [[4, 6], [1, 2, 6]]),
                    BrailleLetter(hangul: "차", englishName: "Cha", cells: [[5, 6], [1, 2, 6]]),
                    BrailleLetter(hangul: "카", englishName: "Ka", cells: [[1, 2, 4], [1, 2, 6]]),
                    BrailleLetter(hangul: "타", englishName: "Ta", cells: [[1, 2, 5], [1, 2, 6]]),
                    BrailleLetter(hangul: "파", englishName: "Pa", cells: [[1, 4, 5], [1, 2, 6]]),
                    BrailleLetter(hangul: "하", englishName: "Ha", cells: [[2, 4, 5], [1, 2, 6]])
                ],
                useLandscape: true
            ),
            
            // Level 2: With Final Consonant (Batchim)
            BrailleLevel(
                title: "Level 2: With Final Consonant",
                storageKey: "sec2_lvl2_completed",
                letters: [
                    BrailleLetter(hangul: "각", englishName: "Gak", cells: [[4], [1, 2, 6], [1]]),
                    BrailleLetter(hangul: "난", englishName: "Nan", cells: [[1, 4], [1, 2, 6], [2, 5]]),
                    BrailleLetter(hangul: "달", englishName: "Dal", cells: [[2, 4], [1, 2, 6], [2]]),
                    BrailleLetter(hangul: "맘", englishName: "Mam", cells: [[1, 5], [1, 2, 6], [2, 6]]),
                    BrailleLetter(hangul: "밥", englishName: "Bap", cells: [[4, 5], [1, 2, 6], [1, 5]]),
                    BrailleLetter(hangul: "삿", englishName: "Sat", cells: [[6], [1, 2, 6], [3]]),
                    BrailleLetter(hangul: "앙", englishName: "Ang", cells: [[1, 2, 6], [1, 2, 4, 5]]),
                    BrailleLetter(hangul: "죽", englishName: "Juk", cells: [[4, 6], [1, 3, 4], [1]]),
                    BrailleLetter(hangul: "착", englishName: "Chak", cells: [[5, 6], [1, 2, 6], [1]]),
                    BrailleLetter(hangul: "탈", englishName: "Tal", cells: [[1, 2, 5], [1, 2, 6], [2]]),
                    BrailleLetter(hangul: "팔", englishName: "Pal", cells: [[1, 4, 5], [1, 2, 6], [2]]),
                    BrailleLetter(hangul: "학", englishName: "Hak", cells: [[2, 4, 5], [1, 2, 6], [1]])
                ],
                useLandscape: true
            )
        ]
    )
    
    static let section3 = BrailleSection(
        title: "Section 3: Words",
        levels: [

            BrailleLevel(
                title: "Level 1: Words",
                storageKey: "sec3_lvl1_completed",
                letters: [
                    BrailleLetter(hangul: "나무", englishName: "Tree", cells: [
                        [1, 4], [1, 2, 6],       // Na
                        [1, 5], [1, 3, 4]        // Mu
                    ]),
                    BrailleLetter(hangul: "바다", englishName: "Ocean", cells: [
                        [4, 5], [1, 2, 6],       // Ba
                        [2, 4], [1, 2, 6]        // Da
                    ]),
                    BrailleLetter(hangul: "우유", englishName: "Milk", cells: [
                        [1, 3, 4],               // U
                        [1, 4, 6]                // Yu
                    ]),
                    BrailleLetter(hangul: "사자", englishName: "Lion", cells: [
                        [6], [1, 2, 6],          // Sa
                        [4, 6], [1, 2, 6]        // Ja
                    ]),
                    BrailleLetter(hangul: "포도", englishName: "Grape", cells: [
                        [1, 4, 5], [1, 3, 6],    // Po
                        [2, 4], [1, 3, 6]        // Do
                    ]),
                    BrailleLetter(hangul: "아기", englishName: "Baby", cells: [
                        [1, 2, 6],               // A
                        [4], [1, 3, 5]           // Gi
                    ]),
                    BrailleLetter(hangul: "오이", englishName: "Cucumber", cells: [
                        [1, 3, 6],               // O
                        [1, 3, 5]                // I
                    ]),
                    BrailleLetter(hangul: "모자", englishName: "Hat", cells: [
                        [1, 5], [1, 3, 6],       // Mo
                        [4, 6], [1, 2, 6]        // Ja
                    ]),
                    BrailleLetter(hangul: "지도", englishName: "Map", cells: [
                        [4, 6], [1, 3, 5],       // Ji
                        [2, 4], [1, 3, 6]        // Do
                    ]),
                    BrailleLetter(hangul: "치마", englishName: "Skirt", cells: [
                        [5, 6], [1, 3, 5],       // Chi
                        [1, 5], [1, 2, 6]        // Ma
                    ])
                ],
                useLandscape: true
            ),

        ]
    )

    // MARK: - Grade 2 (Abbreviated Braille)
    static let yakjaSections: [BrailleSection] = [
        yakjaSection1,
        yakjaSection2
    ]

    // MARK: Syllable & Vowel-Final Abbreviations
    static let yakjaSection1 = BrailleSection(
        title: "Section 1: Abbreviations",
        levels: [
            // Level 1: Consonant+ㅏ syllable abbreviations (single cell each)
            BrailleLevel(
                title: "Level 1: Syllable Abbreviations (가-파)",
                storageKey: "yakja_s1_lvl1_completed",
                letters: [
                    BrailleLetter(hangul: "가", englishName: "Ga", activeDots: [1, 2, 4, 6]),
                    BrailleLetter(hangul: "나", englishName: "Na", activeDots: [1, 4]),
                    BrailleLetter(hangul: "다", englishName: "Da", activeDots: [2, 4]),
                    BrailleLetter(hangul: "마", englishName: "Ma", activeDots: [1, 5]),
                    BrailleLetter(hangul: "바", englishName: "Ba", activeDots: [4, 5]),
                    BrailleLetter(hangul: "사", englishName: "Sa", activeDots: [1, 2, 3]),
                    BrailleLetter(hangul: "자", englishName: "Ja", activeDots: [4, 6]),
                    BrailleLetter(hangul: "카", englishName: "Ka", activeDots: [1, 2, 4]),
                    BrailleLetter(hangul: "타", englishName: "Ta", activeDots: [1, 2, 5]),
                    BrailleLetter(hangul: "파", englishName: "Pa", activeDots: [1, 4, 5])
                ],
                useLandscape: false
            ),

            // Level 2: 하 + vowel-final abbreviations (single cell each)
            BrailleLevel(
                title: "Level 2: Vowel-Final Abbreviations 1",
                storageKey: "yakja_s1_lvl2_completed",
                letters: [
                    BrailleLetter(hangul: "하", englishName: "Ha", activeDots: [2, 4, 5]),
                    BrailleLetter(hangul: "억", englishName: "Eok", activeDots: [1, 4, 5, 6]),
                    BrailleLetter(hangul: "언", englishName: "Eon", activeDots: [2, 3, 4, 5, 6]),
                    BrailleLetter(hangul: "얼", englishName: "Eol", activeDots: [2, 3, 4, 5]),
                    BrailleLetter(hangul: "연", englishName: "Yeon", activeDots: [1, 6]),
                    BrailleLetter(hangul: "열", englishName: "Yeol", activeDots: [1, 2, 5, 6]),
                    BrailleLetter(hangul: "영", englishName: "Yeong", activeDots: [1, 2, 4, 5, 6]),
                    BrailleLetter(hangul: "옥", englishName: "Ok", activeDots: [1, 3, 4, 6]),
                    BrailleLetter(hangul: "온", englishName: "On", activeDots: [1, 2, 3, 5, 6]),
                    BrailleLetter(hangul: "옹", englishName: "Ong", activeDots: [1, 2, 3, 4, 5, 6])
                ],
                useLandscape: false
            )
        ]
    )

    // MARK: Remaining Abbreviations & Word Abbreviations
    static let yakjaSection2 = BrailleSection(
        title: "Section 2: Words & Connectors",
        levels: [
            // Level 1: Remaining abbreviations + 것 + connector abbreviations
            BrailleLevel(
                title: "Level 3: Vowel-Finals 2 & Connectors",
                storageKey: "yakja_s2_lvl1_completed",
                letters: [
                    BrailleLetter(hangul: "운", englishName: "Un", activeDots: [1, 2, 4, 5]),
                    BrailleLetter(hangul: "울", englishName: "Ul", activeDots: [1, 2, 3, 4, 6]),
                    BrailleLetter(hangul: "은", englishName: "Eun", activeDots: [1, 3, 5, 6]),
                    BrailleLetter(hangul: "을", englishName: "Eul", activeDots: [2, 3, 4, 6]),
                    BrailleLetter(hangul: "인", englishName: "In", activeDots: [1, 2, 3, 4, 5]),
                    BrailleLetter(hangul: "것", englishName: "Geot (thing)", cells: [[4, 5, 6], [2, 3, 4]]),
                    BrailleLetter(hangul: "그래서", englishName: "So", cells: [[1], [2, 3, 4]]),
                    BrailleLetter(hangul: "그러나", englishName: "But", cells: [[1], [1, 4]]),
                    BrailleLetter(hangul: "그러면", englishName: "If so", cells: [[1], [2, 5]]),
                    BrailleLetter(hangul: "그러므로", englishName: "Therefore", cells: [[1], [2, 6]])
                ],
                useLandscape: true
            ),

            // Level 2: More connectors + practice words using abbreviations
            BrailleLevel(
                title: "Level 4: Connectors & Practice Words",
                storageKey: "yakja_s2_lvl2_completed",
                letters: [
                    BrailleLetter(hangul: "그런데", englishName: "However", cells: [[1], [1, 3, 4, 5]]),
                    BrailleLetter(hangul: "그리고", englishName: "And", cells: [[1], [1, 3, 6]]),
                    BrailleLetter(hangul: "그리하여", englishName: "Thus", cells: [[1], [1, 5, 6]]),
                    BrailleLetter(hangul: "가다", englishName: "To go", cells: [[1, 2, 4, 6], [2, 4]]),
                    BrailleLetter(hangul: "나다", englishName: "To emerge", cells: [[1, 4], [2, 4]]),
                    BrailleLetter(hangul: "사다", englishName: "To buy", cells: [[1, 2, 3], [2, 4]]),
                    BrailleLetter(hangul: "타다", englishName: "To ride", cells: [[1, 2, 5], [2, 4]]),
                    BrailleLetter(hangul: "하다", englishName: "To do", cells: [[2, 4, 5], [2, 4]]),
                    BrailleLetter(hangul: "바다", englishName: "Ocean", cells: [[4, 5], [2, 4]]),
                    BrailleLetter(hangul: "자다", englishName: "To sleep", cells: [[4, 6], [2, 4]])
                ],
                useLandscape: true
            )
        ]
    )

    static func sections(for type: BrailleType) -> [BrailleSection] {
        switch type {
        case .jeongja: return sections
        case .yakja: return yakjaSections
        }
    }
}
