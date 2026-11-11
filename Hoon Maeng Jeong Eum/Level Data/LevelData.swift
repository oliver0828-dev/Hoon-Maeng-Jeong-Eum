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
        case .jeongja: return "1급"
        case .yakja: return "2급"
        }
    }

    var subtitle: String {
        switch self {
        case .jeongja: return "정자 점자"
        case .yakja: return "약자 점자"
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
        title: "1단원: 기초",
        levels: [
            BrailleLevel(
                title: "1단계: 초성 자음",
                storageKey: "level1_completed",
                letters: [
                    BrailleLetter(hangul: "ㄱ", englishName: "기역", activeDots: [4]),
                    BrailleLetter(hangul: "ㄴ", englishName: "니은", activeDots: [1, 4]),
                    BrailleLetter(hangul: "ㄷ", englishName: "디귿", activeDots: [2, 4]),
                    BrailleLetter(hangul: "ㄹ", englishName: "리을", activeDots: [5]),
                    BrailleLetter(hangul: "ㅁ", englishName: "미음", activeDots: [1, 5]),
                    BrailleLetter(hangul: "ㅂ", englishName: "비읍", activeDots: [4, 5]),
                    BrailleLetter(hangul: "ㅅ", englishName: "시옷", activeDots: [6]),
                    BrailleLetter(hangul: "ㅇ", englishName: "이응", activeDots: []),
                    BrailleLetter(hangul: "ㅈ", englishName: "지읒", activeDots: [4, 6]),
                    BrailleLetter(hangul: "ㅊ", englishName: "치읓", activeDots: [5, 6]),
                    BrailleLetter(hangul: "ㅋ", englishName: "키읔", activeDots: [1, 2, 4]),
                    BrailleLetter(hangul: "ㅌ", englishName: "티읕", activeDots: [1, 2, 5]),
                    BrailleLetter(hangul: "ㅍ", englishName: "피읖", activeDots: [1, 4, 5]),
                    BrailleLetter(hangul: "ㅎ", englishName: "히읗", activeDots: [2, 4, 5]),
                    BrailleLetter(hangul: "된소리", englishName: "된소리표", activeDots: [6])
                ],
                useLandscape: false
            ),
            BrailleLevel(
                title: "2단계: 모음 1 (기본)",
                storageKey: "level2_completed",
                letters: [
                    BrailleLetter(hangul: "ㅏ", englishName: "아", activeDots: [1, 2, 6]),
                    BrailleLetter(hangul: "ㅑ", englishName: "야", activeDots: [3, 4, 5]),
                    BrailleLetter(hangul: "ㅓ", englishName: "어", activeDots: [2, 3, 4]),
                    BrailleLetter(hangul: "ㅕ", englishName: "여", activeDots: [1, 5, 6]),
                    BrailleLetter(hangul: "ㅗ", englishName: "오", activeDots: [1, 3, 6]),
                    BrailleLetter(hangul: "ㅛ", englishName: "요", activeDots: [3, 4, 6]),
                    BrailleLetter(hangul: "ㅜ", englishName: "우", activeDots: [1, 3, 4]),
                    BrailleLetter(hangul: "ㅠ", englishName: "유", activeDots: [1, 4, 6]),
                    BrailleLetter(hangul: "ㅡ", englishName: "으", activeDots: [2, 4, 6]),
                    BrailleLetter(hangul: "ㅣ", englishName: "이", activeDots: [1, 3, 5]),
                    BrailleLetter(hangul: "ㅔ", englishName: "에", activeDots: [1, 3, 4, 5]),
                    BrailleLetter(hangul: "ㅐ", englishName: "애", activeDots: [1, 2, 3, 5])
                ],
                useLandscape: false
            ),
          
            BrailleLevel(
                title: "3단계: 모음 2 (복합)",
                storageKey: "level4_completed",
                letters: [
                    BrailleLetter(hangul: "ㅔ", englishName: "에", activeDots: [1, 3, 4, 5]),
                    BrailleLetter(hangul: "ㅐ", englishName: "애", activeDots: [1, 2, 3, 5]),
                    BrailleLetter(hangul: "ㅖ", englishName: "예", cells: [[3, 4], [1, 3, 4, 5]]),
                    BrailleLetter(hangul: "ㅒ", englishName: "얘", cells: [[3, 4, 5], [1, 2, 3, 5]]),
                    BrailleLetter(hangul: "ㅘ", englishName: "와", cells: [[1, 2, 3, 6], [1, 2, 3, 5]]),
                    BrailleLetter(hangul: "ㅙ", englishName: "왜", cells: [[1, 2, 3, 6], [1, 2, 3, 5]]),
                    BrailleLetter(hangul: "ㅚ", englishName: "외", cells: [[1, 3, 4, 5, 6]]),
                    BrailleLetter(hangul: "ㅝ", englishName: "워", cells: [[1, 3, 4, 5, 6], [2, 3, 4]]),
                    BrailleLetter(hangul: "ㅞ", englishName: "웨", cells: [[1, 3, 4, 5, 6], [1, 3, 4, 5]]),
                    BrailleLetter(hangul: "ㅟ", englishName: "위", cells: [[1, 3, 4, 5, 6], [1, 2, 3, 5]]),
                    BrailleLetter(hangul: "ㅢ", englishName: "의", cells: [[2, 4, 6], [1, 3, 5]])
                ],
                useLandscape: true
            )
        ]
    )
    
    // MARK: Section 2
    static let section2 = BrailleSection(
        title: "2단원: 음절",
        levels: [
          
            BrailleLevel(
                title: "1단계: 가나다 (기본 음절)",
                storageKey: "sec2_lvl1_completed",
                letters: [
                    BrailleLetter(hangul: "가", englishName: "가", cells: [[4], [1, 2, 6]]),
                    BrailleLetter(hangul: "나", englishName: "나", cells: [[1, 4], [1, 2, 6]]),
                    BrailleLetter(hangul: "다", englishName: "다", cells: [[2, 4], [1, 2, 6]]),
                    BrailleLetter(hangul: "라", englishName: "라", cells: [[5], [1, 2, 6]]),
                    BrailleLetter(hangul: "마", englishName: "마", cells: [[1, 5], [1, 2, 6]]),
                    BrailleLetter(hangul: "바", englishName: "바", cells: [[4, 5], [1, 2, 6]]),
                    BrailleLetter(hangul: "사", englishName: "사", cells: [[6], [1, 2, 6]]),
                    BrailleLetter(hangul: "아", englishName: "아", cells: [[1, 2, 6]]),
                    BrailleLetter(hangul: "자", englishName: "자", cells: [[4, 6], [1, 2, 6]]),
                    BrailleLetter(hangul: "차", englishName: "차", cells: [[5, 6], [1, 2, 6]]),
                    BrailleLetter(hangul: "카", englishName: "카", cells: [[1, 2, 4], [1, 2, 6]]),
                    BrailleLetter(hangul: "타", englishName: "타", cells: [[1, 2, 5], [1, 2, 6]]),
                    BrailleLetter(hangul: "파", englishName: "파", cells: [[1, 4, 5], [1, 2, 6]]),
                    BrailleLetter(hangul: "하", englishName: "하", cells: [[2, 4, 5], [1, 2, 6]])
                ],
                useLandscape: true
            ),
            
            // Level 2: With Final Consonant (Batchim)
            BrailleLevel(
                title: "2단계: 받침이 있는 글자",
                storageKey: "sec2_lvl2_completed",
                letters: [
                    BrailleLetter(hangul: "각", englishName: "각", cells: [[4], [1, 2, 6], [1]]),
                    BrailleLetter(hangul: "난", englishName: "난", cells: [[1, 4], [1, 2, 6], [2, 5]]),
                    BrailleLetter(hangul: "달", englishName: "달", cells: [[2, 4], [1, 2, 6], [2]]),
                    BrailleLetter(hangul: "맘", englishName: "맘", cells: [[1, 5], [1, 2, 6], [2, 6]]),
                    BrailleLetter(hangul: "밥", englishName: "밥", cells: [[4, 5], [1, 2, 6], [1, 5]]),
                    BrailleLetter(hangul: "삿", englishName: "삿", cells: [[6], [1, 2, 6], [3]]),
                    BrailleLetter(hangul: "앙", englishName: "앙", cells: [[1, 2, 6], [1, 2, 4, 5]]),
                    BrailleLetter(hangul: "죽", englishName: "죽", cells: [[4, 6], [1, 3, 4], [1]]),
                    BrailleLetter(hangul: "착", englishName: "착", cells: [[5, 6], [1, 2, 6], [1]]),
                    BrailleLetter(hangul: "탈", englishName: "탈", cells: [[1, 2, 5], [1, 2, 6], [2]]),
                    BrailleLetter(hangul: "팔", englishName: "팔", cells: [[1, 4, 5], [1, 2, 6], [2]]),
                    BrailleLetter(hangul: "학", englishName: "학", cells: [[2, 4, 5], [1, 2, 6], [1]])
                ],
                useLandscape: true
            )
        ]
    )
    
    static let section3 = BrailleSection(
        title: "3단원: 단어",
        levels: [

            BrailleLevel(
                title: "1단계: 단어",
                storageKey: "sec3_lvl1_completed",
                letters: [
                    BrailleLetter(hangul: "나무", englishName: "나무", cells: [
                        [1, 4], [1, 2, 6],       // Na
                        [1, 5], [1, 3, 4]        // Mu
                    ]),
                    BrailleLetter(hangul: "바다", englishName: "바다", cells: [
                        [4, 5], [1, 2, 6],       // Ba
                        [2, 4], [1, 2, 6]        // Da
                    ]),
                    BrailleLetter(hangul: "우유", englishName: "우유", cells: [
                        [1, 3, 4],               // U
                        [1, 4, 6]                // Yu
                    ]),
                    BrailleLetter(hangul: "사자", englishName: "사자", cells: [
                        [6], [1, 2, 6],          // Sa
                        [4, 6], [1, 2, 6]        // Ja
                    ]),
                    BrailleLetter(hangul: "포도", englishName: "포도", cells: [
                        [1, 4, 5], [1, 3, 6],    // Po
                        [2, 4], [1, 3, 6]        // Do
                    ]),
                    BrailleLetter(hangul: "아기", englishName: "아기", cells: [
                        [1, 2, 6],               // A
                        [4], [1, 3, 5]           // Gi
                    ]),
                    BrailleLetter(hangul: "오이", englishName: "오이", cells: [
                        [1, 3, 6],               // O
                        [1, 3, 5]                // I
                    ]),
                    BrailleLetter(hangul: "모자", englishName: "모자", cells: [
                        [1, 5], [1, 3, 6],       // Mo
                        [4, 6], [1, 2, 6]        // Ja
                    ]),
                    BrailleLetter(hangul: "지도", englishName: "지도", cells: [
                        [4, 6], [1, 3, 5],       // Ji
                        [2, 4], [1, 3, 6]        // Do
                    ]),
                    BrailleLetter(hangul: "치마", englishName: "치마", cells: [
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
        title: "1단원: 약자",
        levels: [
            // Level 1: Consonant+ㅏ syllable abbreviations (single cell each)
            BrailleLevel(
                title: "1단계: 음절 약자 (가-파)",
                storageKey: "yakja_s1_lvl1_completed",
                letters: [
                    BrailleLetter(hangul: "가", englishName: "가", activeDots: [1, 2, 4, 6]),
                    BrailleLetter(hangul: "나", englishName: "나", activeDots: [1, 4]),
                    BrailleLetter(hangul: "다", englishName: "다", activeDots: [2, 4]),
                    BrailleLetter(hangul: "마", englishName: "마", activeDots: [1, 5]),
                    BrailleLetter(hangul: "바", englishName: "바", activeDots: [4, 5]),
                    BrailleLetter(hangul: "사", englishName: "사", activeDots: [1, 2, 3]),
                    BrailleLetter(hangul: "자", englishName: "자", activeDots: [4, 6]),
                    BrailleLetter(hangul: "카", englishName: "카", activeDots: [1, 2, 4]),
                    BrailleLetter(hangul: "타", englishName: "타", activeDots: [1, 2, 5]),
                    BrailleLetter(hangul: "파", englishName: "파", activeDots: [1, 4, 5])
                ],
                useLandscape: false
            ),

            // Level 2: 하 + vowel-final abbreviations (single cell each)
            BrailleLevel(
                title: "2단계: 모음·받침 약자 1",
                storageKey: "yakja_s1_lvl2_completed",
                letters: [
                    BrailleLetter(hangul: "하", englishName: "하", activeDots: [2, 4, 5]),
                    BrailleLetter(hangul: "억", englishName: "억", activeDots: [1, 4, 5, 6]),
                    BrailleLetter(hangul: "언", englishName: "언", activeDots: [2, 3, 4, 5, 6]),
                    BrailleLetter(hangul: "얼", englishName: "얼", activeDots: [2, 3, 4, 5]),
                    BrailleLetter(hangul: "연", englishName: "연", activeDots: [1, 6]),
                    BrailleLetter(hangul: "열", englishName: "열", activeDots: [1, 2, 5, 6]),
                    BrailleLetter(hangul: "영", englishName: "영", activeDots: [1, 2, 4, 5, 6]),
                    BrailleLetter(hangul: "옥", englishName: "옥", activeDots: [1, 3, 4, 6]),
                    BrailleLetter(hangul: "온", englishName: "온", activeDots: [1, 2, 3, 5, 6]),
                    BrailleLetter(hangul: "옹", englishName: "옹", activeDots: [1, 2, 3, 4, 5, 6])
                ],
                useLandscape: false
            )
        ]
    )

    // MARK: Remaining Abbreviations & Word Abbreviations
    static let yakjaSection2 = BrailleSection(
        title: "2단원: 단어와 접속어",
        levels: [
            // Level 1: Remaining abbreviations + 것 + connector abbreviations
            BrailleLevel(
                title: "3단계: 모음·받침 약자 2와 접속어",
                storageKey: "yakja_s2_lvl1_completed",
                letters: [
                    BrailleLetter(hangul: "운", englishName: "운", activeDots: [1, 2, 4, 5]),
                    BrailleLetter(hangul: "울", englishName: "울", activeDots: [1, 2, 3, 4, 6]),
                    BrailleLetter(hangul: "은", englishName: "은", activeDots: [1, 3, 5, 6]),
                    BrailleLetter(hangul: "을", englishName: "을", activeDots: [2, 3, 4, 6]),
                    BrailleLetter(hangul: "인", englishName: "인", activeDots: [1, 2, 3, 4, 5]),
                    BrailleLetter(hangul: "것", englishName: "것 (사물)", cells: [[4, 5, 6], [2, 3, 4]]),
                    BrailleLetter(hangul: "그래서", englishName: "그래서", cells: [[1], [2, 3, 4]]),
                    BrailleLetter(hangul: "그러나", englishName: "그러나", cells: [[1], [1, 4]]),
                    BrailleLetter(hangul: "그러면", englishName: "그러면", cells: [[1], [2, 5]]),
                    BrailleLetter(hangul: "그러므로", englishName: "그러므로", cells: [[1], [2, 6]])
                ],
                useLandscape: true
            ),

            // Level 2: More connectors + practice words using abbreviations
            BrailleLevel(
                title: "4단계: 접속어와 연습 단어",
                storageKey: "yakja_s2_lvl2_completed",
                letters: [
                    BrailleLetter(hangul: "그런데", englishName: "그런데", cells: [[1], [1, 3, 4, 5]]),
                    BrailleLetter(hangul: "그리고", englishName: "그리고", cells: [[1], [1, 3, 6]]),
                    BrailleLetter(hangul: "그리하여", englishName: "그리하여", cells: [[1], [1, 5, 6]]),
                    BrailleLetter(hangul: "가다", englishName: "가다", cells: [[1, 2, 4, 6], [2, 4]]),
                    BrailleLetter(hangul: "나다", englishName: "나다", cells: [[1, 4], [2, 4]]),
                    BrailleLetter(hangul: "사다", englishName: "사다", cells: [[1, 2, 3], [2, 4]]),
                    BrailleLetter(hangul: "타다", englishName: "타다", cells: [[1, 2, 5], [2, 4]]),
                    BrailleLetter(hangul: "하다", englishName: "하다", cells: [[2, 4, 5], [2, 4]]),
                    BrailleLetter(hangul: "바다", englishName: "바다", cells: [[4, 5], [2, 4]]),
                    BrailleLetter(hangul: "자다", englishName: "자다", cells: [[4, 6], [2, 4]])
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
