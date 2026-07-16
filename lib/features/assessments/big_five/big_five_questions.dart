// ═══════════════════════════════════════════════════════════════════════
// BigFiveQuestions — 10 HK-situational Cantonese questions
// 2 questions per OCEAN dimension, 5-point Likert scale
// ═══════════════════════════════════════════════════════════════════════

import 'big_five_model.dart';

class BigFiveQuestions {
  static List<BigFiveQuestion> get all => [
        // ─── O: Openness ───
        const BigFiveQuestion(
          id: 'O1',
          dimension: 'O',
          scenario: '你見到一間新開嘅餐廳，菜式係你未試過嘅異國料理，你會…',
          options: [
            BigFiveOption(text: '即刻想去試，新嘢正', score: 5),
            BigFiveOption(text: '有啲興趣，但睇定啲先', score: 4),
            BigFiveOption(text: '中立', score: 3),
            BigFiveOption(text: '都係食返穩陣啲嘅餐廳', score: 2),
            BigFiveOption(text: '新嘢冇保證，唔會去', score: 1),
          ],
        ),
        const BigFiveQuestion(
          id: 'O2',
          dimension: 'O',
          scenario: '你朋友提出一個好 unconventional 嘅解決方案，你第一個反應係…',
          options: [
            BigFiveOption(text: '好有創意！試下無妨', score: 5),
            BigFiveOption(text: '有啲冒險，但可以考慮', score: 4),
            BigFiveOption(text: '中立', score: 3),
            BigFiveOption(text: '覺得唔太可行', score: 2),
            BigFiveOption(text: '太離譜啦，唔會 work', score: 1),
          ],
        ),

        // ─── C: Conscientiousness ───
        const BigFiveQuestion(
          id: 'C1',
          dimension: 'C',
          scenario: '星期日夜晚，你聽日有份報告要交，但你仲未開始，你會…',
          options: [
            BigFiveOption(text: '即刻開工做到完先瞓', score: 5),
            BigFiveOption(text: '做一陣，聽朝再繼續', score: 4),
            BigFiveOption(text: '聽朝先做啦', score: 3),
            BigFiveOption(text: '睇吓有冇得延遲', score: 2),
            BigFiveOption(text: '算啦，遲一日俾人鬧都冇計', score: 1),
          ],
        ),
        const BigFiveQuestion(
          id: 'C2',
          dimension: 'C',
          scenario: '你嘅書桌／工作空間通常係…',
          options: [
            BigFiveOption(text: '分類整齊，每樣嘢有固定位置', score: 5),
            BigFiveOption(text: '大部分時間整齊', score: 4),
            BigFiveOption(text: '有時亂有時整齊', score: 3),
            BigFiveOption(text: '有啲亂，但我知喺邊', score: 2),
            BigFiveOption(text: '災難現場，但係 creative chaos', score: 1),
          ],
        ),

        // ─── E: Extraversion ───
        const BigFiveQuestion(
          id: 'E1',
          dimension: 'E',
          scenario: '星期五放工，你嘅理想活動係…',
          options: [
            BigFiveOption(text: '約一大班朋友出去玩', score: 5),
            BigFiveOption(text: '約幾個 friend 食飯', score: 4),
            BigFiveOption(text: '同屋企人或伴侶 chill', score: 3),
            BigFiveOption(text: '自己喺屋企睇戲打機', score: 2),
            BigFiveOption(text: '最好冇人搵我，我想靜靜', score: 1),
          ],
        ),
        const BigFiveQuestion(
          id: 'E2',
          dimension: 'E',
          scenario: '你出席一個社交場合（例如 party / networking），你多數係…',
          options: [
            BigFiveOption(text: '全場最活躍，周圍識人', score: 5),
            BigFiveOption(text: '主動同人傾偈但唔係核心', score: 4),
            BigFiveOption(text: '同熟人傾多，間中識新朋友', score: 3),
            BigFiveOption(text: '留喺角落等完場', score: 2),
            BigFiveOption(text: '如果可以揀，我根本唔會去', score: 1),
          ],
        ),

        // ─── A: Agreeableness ───
        const BigFiveQuestion(
          id: 'A1',
          dimension: 'A',
          scenario: '同事做錯嘢影響到你個 project，佢道歉，你會…',
          options: [
            BigFiveOption(text: '冇問題，人誰無過，一齊 fix', score: 5),
            BigFiveOption(text: '接受道歉但提醒佢下次小心', score: 4),
            BigFiveOption(text: '有啲唔高興但表面 OK', score: 3),
            BigFiveOption(text: '覺得佢唔專業，好煩', score: 2),
            BigFiveOption(text: '忍唔住要話佢幾句', score: 1),
          ],
        ),
        const BigFiveQuestion(
          id: 'A2',
          dimension: 'A',
          scenario: '你同朋友有政治／宗教嘅重大分歧，你會…',
          options: [
            BigFiveOption(text: '尊重佢，友誼緊要過立場', score: 5),
            BigFiveOption(text: '可以討論但唔想影響感情', score: 4),
            BigFiveOption(text: '避開呢個話題', score: 3),
            BigFiveOption(text: '忍唔住要辯論', score: 2),
            BigFiveOption(text: '覺得佢好無知，好難做朋友', score: 1),
          ],
        ),

        // ─── N: Neuroticism ───
        const BigFiveQuestion(
          id: 'N1',
          dimension: 'N',
          scenario: '你等緊一個重要結果（例如見工結果／考試成績），你會…',
          options: [
            BigFiveOption(text: '照常生活，冇咩特別感覺', score: 1),
            BigFiveOption(text: '有少少期待但唔影響生活', score: 2),
            BigFiveOption(text: '有啲緊張，成日 check 電話', score: 3),
            BigFiveOption(text: '好焦慮，瞓唔著諗 worst case', score: 4),
            BigFiveOption(text: '崩潰邊緣，完全集中唔到做其他嘢', score: 5),
          ],
        ),
        const BigFiveQuestion(
          id: 'N2',
          dimension: 'N',
          scenario: '你俾人批評（例如老細話你做得唔好），你會…',
          options: [
            BigFiveOption(text: '理性分析，有則改之', score: 1),
            BigFiveOption(text: '有少少唔開心但 okay', score: 2),
            BigFiveOption(text: '會諗幾日', score: 3),
            BigFiveOption(text: '好大打擊，覺得自己冇用', score: 4),
            BigFiveOption(text: '失眠加不斷 replay 句說話', score: 5),
          ],
        ),
      ];
}
