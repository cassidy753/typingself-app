#!/usr/bin/env python3
"""
Generate all 288 MBTI × Enneagram naming entries for NamingEngine.
Outputs valid Dart code to be inserted into naming_engine.dart.

16 MBTI × 18 Enneagram = 288 total entries.
"""
import textwrap

# ── MBTI base profiles ──────────────────────────────────────────────
# Each MBTI has: emoji, base_name (Cantonese archetype)
MBTI_BASE = {
    # ── Analysts (NT) ──
    'INTJ': {'emoji': '♟️', 'base': '戰略軍師'},
    'INTP': {'emoji': '🔬', 'base': '概念建築師'},
    'ENTJ': {'emoji': '👑', 'base': '宏圖指揮官'},
    'ENTP': {'emoji': '🔥', 'base': '創新辯士'},
    # ── Diplomats (NF) ──
    'INFJ': {'emoji': '🔮', 'base': '靈魂引渡者'},
    'INFP': {'emoji': '🌙', 'base': '夢境織造者'},
    'ENFJ': {'emoji': '🌟', 'base': '人群點燈者'},
    'ENFP': {'emoji': '🌈', 'base': '靈感拓荒者'},
    # ── Sentinels (SJ) ──
    'ISTJ': {'emoji': '⚖️', 'base': '堅實磐石'},
    'ISFJ': {'emoji': '🏡', 'base': '無聲守護者'},
    'ESTJ': {'emoji': '📊', 'base': '秩序建造者'},
    'ESFJ': {'emoji': '🤝', 'base': '社群樞紐'},
    # ── Explorers (SP) ──
    'ISTP': {'emoji': '🔧', 'base': '寂靜工匠'},
    'ISFP': {'emoji': '🎨', 'base': '靜美藝術家'},
    'ESTP': {'emoji': '🎯', 'base': '行動冒險家'},
    'ESFP': {'emoji': '🎉', 'base': '活力展演者'},
}

# ── Enneagram profiles ──────────────────────────────────────────────
ENNEAGRAM = {
    '1w9': {'drive': '追求完美但溫和', 'strength': '原則與平和並存'},
    '1w2': {'drive': '追求完美兼幫助他人', 'strength': '高標準與服務心'},
    '2w1': {'drive': '渴望被愛同時堅守原則', 'strength': '溫暖與責任感'},
    '2w3': {'drive': '渴望被愛同時追求成就', 'strength': '關懷與魅力'},
    '3w2': {'drive': '追求成功兼照顧他人', 'strength': '效率與人脈'},
    '3w4': {'drive': '追求成功同時忠於自我', 'strength': '成就與深度'},
    '4w3': {'drive': '追求獨特同時渴望認同', 'strength': '創造力與表現力'},
    '4w5': {'drive': '追求深度同時保持距離', 'strength': '洞察與原創'},
    '5w4': {'drive': '渴求知識同時追求美', 'strength': '智慧與創造'},
    '5w6': {'drive': '渴求知識同時尋求安全', 'strength': '分析與準備'},
    '6w5': {'drive': '尋求安全同時依賴智慧', 'strength': '忠誠與深思'},
    '6w7': {'drive': '尋求安全同時渴望樂趣', 'strength': '警覺與幽默'},
    '7w6': {'drive': '追求快樂同時需要安全', 'strength': '熱情與謹慎'},
    '7w8': {'drive': '追求快樂同時追求權力', 'strength': '冒險與魄力'},
    '8w7': {'drive': '追求力量同時享受生活', 'strength': '果斷與活力'},
    '8w9': {'drive': '追求力量同時渴求和平', 'strength': '強大與包容'},
    '9w8': {'drive': '渴求和平同時保有力量', 'strength': '包容與堅定'},
    '9w1': {'drive': '渴求和平同時堅守原則', 'strength': '和諧與正直'},
}

# ── Keys preserved from the original 16 (these won't be re-generated) ──
EXISTING_KEYS = {
    'ENFJ_5w4', 'ENFP_7w4',   # 7w4 is non-standard but preserved
    'ENTJ_8w7', 'ENTP_7w6',
    'ESFJ_2w3', 'ESFP_7w6',
    'ESTJ_1w2', 'ESTP_7w8',
    'INFJ_4w5', 'INFP_4w5',
    'INTJ_5w6', 'INTP_5w6',
    'ISFJ_9w1', 'ISFP_9w8',
    'ISTJ_1w9', 'ISTP_5w6',
}


def generate_name_canto(mbti, enneagram):
    """Generate a unique nameCanto for each MBTI × Enneagram combo."""
    base = MBTI_BASE[mbti]['base']
    modifiers = {
        '1w9': '·完美溫和版', '1w2': '·改革支援版',
        '2w1': '·無私守則版', '2w3': '·熱心成就版',
        '3w2': '·耀眼協作版', '3w4': '·真實成就版',
        '4w3': '·獨特展演版', '4w5': '·深度原創版',
        '5w4': '·博學創作版', '5w6': '·系統思維版',
        '6w5': '·審慎智慧版', '6w7': '·靈活應變版',
        '7w6': '·歡樂策劃版', '7w8': '·大膽前進版',
        '8w7': '·強大享樂版', '8w9': '·從容掌控版',
        '9w8': '·溫和堅韌版', '9w1': '·和諧原則版',
    }
    return f"{base}{modifiers[enneagram]}"


# ── All 288 taglines ────────────────────────────────────────────────
TAGLINES = {
    ('INTJ', '1w9'): '你腦內嘅完美藍圖無人能及，但要記住世界唔係non-linear',
    ('INTJ', '1w2'): '你唔單止想做好件事，仲想幫成個系統升級，但要俾人喘氣',
    ('INTJ', '2w1'): '你幫人都有自己一套標準，但有時都要放寬啲',
    ('INTJ', '2w3'): '你暗中幫人仲要幫到最好睇，但自己嘅嘢呢？',
    ('INTJ', '3w2'): '你要贏同時要人鍾意你，野心同人脈你都要',
    ('INTJ', '3w4'): '你唔止要成功，仲要有型有深度，要求真係高',
    ('INTJ', '4w3'): '你既要與別不同又要得到掌聲，矛盾但迷人',
    ('INTJ', '4w5'): '你寧願孤獨都要保持深度，但有時出嚟行下啦',
    ('INTJ', '5w4'): '你鍾意研究奇特嘢仲要研究到出神入化',
    ('INTJ', '5w6'): '你永遠喺度 build 系統同 contingency plan',
    ('INTJ', '6w5'): '你想信自己嘅分析，但又成日質疑，好攰㗎',
    ('INTJ', '6w7'): '你一邊擔心未來一邊搵 fun，好矛盾但好有趣',
    ('INTJ', '7w6'): '你個腦同時 run 緊十個計劃，但每個都要 back up',
    ('INTJ', '7w8'): '你唔只想試新嘢，仲要試到最盡最大',
    ('INTJ', '8w7'): '你要 control 一切，但都要留空間享受成果',
    ('INTJ', '8w9'): '你有 power 但唔需要 show off，低調嘅強者',
    ('INTJ', '9w8'): '你表面平靜但內心有團火，係溫柔嘅力量',
    ('INTJ', '9w1'): '你追求和諧但心中有把尺，平衡係你嘅藝術',

    ('INTP', '1w9'): '你追求理論嘅完美，但完美係process唔係destination',
    ('INTP', '1w2'): '你覺得知識應該服務人類，理想主義者',
    ('INTP', '2w1'): '你分享知識時好有原則，唔係人人都肯教',
    ('INTP', '2w3'): '你鍾意 show off 你幾聰明，但你其實真係好聰明',
    ('INTP', '3w2'): '你想被認同係 genius，但又要保持謙遜，好攰㗎',
    ('INTP', '3w4'): '你嘅理論要有 style，唔可以平凡',
    ('INTP', '4w3'): '你覺得自己嘅諗法係藝術品，同埋要俾人欣賞',
    ('INTP', '4w5'): '你沉迷於自己嘅思想迷宮，但有時要出返嚟',
    ('INTP', '5w4'): '你研究嘢係為咗美，而唔係為咗用，純粹嘅智慧',
    ('INTP', '5w6'): '你嘅知識體系要夠完整先安心，數據狂人',
    ('INTP', '6w5'): '你質疑一切，包括自己嘅質疑，無限 loop',
    ('INTP', '6w7'): '你對世界充滿好奇但又保持警惕，矛盾但迷人',
    ('INTP', '7w6'): '你乜都想研究吓，但每個topic都要有深度',
    ('INTP', '7w8'): '你唔怕挑釁主流觀點，仲要推到極致',
    ('INTP', '8w7'): '你嘅智力係武器，但你選擇用嚟拆解而唔係攻擊',
    ('INTP', '8w9'): '你對 nonsense 零容忍，但 choose your battles',
    ('INTP', '9w8'): '你內心有好多 ideas，但唔急住話俾人聽',
    ('INTP', '9w1'): '你嘅腦袋永遠喺度分類同歸納，搵出真理',

    ('ENTJ', '1w9'): '你唔單止要贏，仲要以最完美嘅方式贏',
    ('ENTJ', '1w2'): '你帶團隊唔止要成果，仲要 everyone grows',
    ('ENTJ', '2w1'): '你幫人成長係有 purpose 嘅，唔係為咗討好',
    ('ENTJ', '2w3'): '你領導嘅方式係帶住人一齊贏，唔係自己贏',
    ('ENTJ', '3w2'): '你唔淨止要成功，仲要成功得受人愛戴',
    ('ENTJ', '3w4'): '你追求卓越，但係以你獨特嘅風格',
    ('ENTJ', '4w3'): '你想做領袖入面最有品味嗰個',
    ('ENTJ', '4w5'): '你嘅 vision 有深度，唔係得個殼',
    ('ENTJ', '5w4'): '你靠智慧領導，唔係靠把聲大',
    ('ENTJ', '5w6'): '你做每一個決定之前都有晒 data backing',
    ('ENTJ', '6w5'): '你信自己嘅判斷，但永遠有 back up plan',
    ('ENTJ', '6w7'): '你大膽進取但步步為營，好有策略',
    ('ENTJ', '7w6'): '你唔怕改變，但每次變都有 reason',
    ('ENTJ', '7w8'): '你嘅 vision 大到嚇親人，但你 carry 得到',
    ('ENTJ', '8w7'): '你天生就係要 lead，冇人質疑你',
    ('ENTJ', '8w9'): '你有權威但唔濫用，係成熟嘅領導者',
    ('ENTJ', '9w8'): '你 calm 咁掌控大局，唔需要大聲',
    ('ENTJ', '9w1'): '你帶領團隊走向和諧共贏，唔係獨裁',

    ('ENTP', '1w9'): '你辯論都要辯到完美，對家冇位入',
    ('ENTP', '1w2'): '你 challenge 人係因為你想幫佢進步',
    ('ENTP', '2w1'): '你同人 debate 時其實好 care 對方感受',
    ('ENTP', '2w3'): '你 argue 贏之餘仲要人覺得你好有魅力',
    ('ENTP', '3w2'): '你唔只想贏個 argument，仲想得到認同',
    ('ENTP', '3w4'): '你嘅 ideas 要 original 先值得講出口',
    ('ENTP', '4w3'): '你啲 idea 又爆又靚，但你唔肯停喺一個',
    ('ENTP', '4w5'): '你鍾意探討離經叛道嘅 concept，越 deep 越好',
    ('ENTP', '5w4'): '你嘅 arguments 背後有深厚嘅知識支撐',
    ('ENTP', '5w6'): '你辯論前已經諗好晒對方會點反駁',
    ('ENTP', '6w5'): '你鍾意 challenge authority，但會做足 research',
    ('ENTP', '6w7'): '你 rapid fire 咁出 ideas，但要小心 burn out',
    ('ENTP', '7w6'): '你嘅腦袋係 idea factory，24/7 不停運作',
    ('ENTP', '7w8'): '你唔怕得罪人，真理比 feeling 重要',
    ('ENTP', '8w7'): '你 debate 時氣場強大，對手未開口已輸一半',
    ('ENTP', '8w9'): '你選擇性出手，但一出手就致命',
    ('ENTP', '9w8'): '你內心好多意見，但會揀時機先講',
    ('ENTP', '9w1'): '你鍾意 intellectual harmony，但唔代表冇立場',

    ('INFJ', '1w9'): '你對世界嘅理想藍圖好清晰，但要接受現實嘅 imperfect',
    ('INFJ', '1w2'): '你想改變世界，而且係以最有同理心嘅方式',
    ('INFJ', '2w1'): '你幫人幫到有原則，唔係盲目付出',
    ('INFJ', '2w3'): '你默默支持每一個人，但都要記得照顧自己',
    ('INFJ', '3w2'): '你想對世界有影響力，同時想被人欣賞',
    ('INFJ', '3w4'): '你嘅使命感要有深度，唔係表面風光',
    ('INFJ', '4w3'): '你嘅靈魂好豐富，但有時好想被人明白',
    ('INFJ', '4w5'): '你睇穿人心嘅能力係天賦，但唔好攰親自己',
    ('INFJ', '5w4'): '你對人性嘅理解有學術級嘅深度',
    ('INFJ', '5w6'): '你洞察人心，但同時分析到背後嘅 system',
    ('INFJ', '6w5'): '你感受到周圍嘅 energy，同時保持警惕',
    ('INFJ', '6w7'): '你既 sensitive 又 curious，係好珍貴嘅組合',
    ('INFJ', '7w6'): '你對未來充滿想像，但又有啲不安',
    ('INFJ', '7w8'): '你嘅 vision 大到想改變世界，而且你真係會試',
    ('INFJ', '8w7'): '你溫柔但強大，冇人估到你內心咁有力量',
    ('INFJ', '8w9'): '你嘅直覺同力量結合，係和平嘅守護者',
    ('INFJ', '9w8'): '你 calm 但唔係 passive，內心有堅定嘅立場',
    ('INFJ', '9w1'): '你用同理心去建立和諧，係真正嘅和平使者',

    ('INFP', '1w9'): '你嘅內心道德標準好高，但你溫柔到唔想傷人',
    ('INFP', '1w2'): '你想為世界帶嚟美好，而且係 action 嗰種',
    ('INFP', '2w1'): '你付出愛時有自己嘅原則，唔係討好型',
    ('INFP', '2w3'): '你想被人欣賞你嘅善良，但善良本身 already 夠',
    ('INFP', '3w2'): '你嘅創作想被人睇到，但更想被人理解',
    ('INFP', '3w4'): '你嘅藝術要有 authenticity，唔係為流行',
    ('INFP', '4w3'): '你想與眾不同，但又好想有人共鳴',
    ('INFP', '4w5'): '你內心世界係一個宇宙咁大，係你嘅避風港',
    ('INFP', '5w4'): '你將情感化為詩歌同藝術，好有天份',
    ('INFP', '5w6'): '你理解世界嘅方式係透過故事同符號',
    ('INFP', '6w5'): '你對世界好敏感，但用創作去消化不安',
    ('INFP', '6w7'): '你喺夢想同現實之間搖擺，但都係你',
    ('INFP', '7w6'): '你嘅想像力無限，但有時需要落返地',
    ('INFP', '7w8'): '你唔怕探索黑暗嘅主題，因為你信光',
    ('INFP', '8w7'): '你溫柔嘅外表下有強大嘅信念',
    ('INFP', '8w9'): '你為了保護心中嘅價值可以好堅定',
    ('INFP', '9w8'): '你隨和但唔係冇主見，只係揀 battles',
    ('INFP', '9w1'): '你追求 inner peace 同外在和諧嘅平衡',

    ('ENFJ', '1w9'): '你想帶領大家去最好嘅地方，而且要有 dignity',
    ('ENFJ', '1w2'): '你 inspire 人嘅方式係以身作則',
    ('ENFJ', '2w1'): '你付出嘅愛中有 boundary，係成熟嘅關懷',
    ('ENFJ', '2w3'): '你照顧每一個人，仲要照顧得好好睇睇',
    ('ENFJ', '3w2'): '你嘅領導魅力令人信服，但你更想人成長',
    ('ENFJ', '3w4'): '你帶動群眾嘅方式好有感染力同深度',
    ('ENFJ', '4w3'): '你希望每個人嘅 unique 都被看見',
    ('ENFJ', '4w5'): '你對人性嘅理解好深，係天生嘅 mentor',
    ('ENFJ', '5w4'): '你教人嘅時候充滿智慧同優雅',
    ('ENFJ', '5w6'): '你帶領團隊時有晒計劃，唔係淨係講夢想',
    ('ENFJ', '6w5'): '你為人著想嘅同時會考慮所有風險',
    ('ENFJ', '6w7'): '你令身邊人 feel safe 又充滿希望',
    ('ENFJ', '7w6'): '你嘅正能量感染全場，但不忘照顧細節',
    ('ENFJ', '7w8'): '你激勵人嘅方式係大膽又充滿熱情',
    ('ENFJ', '8w7'): '你溫柔但 powerful，係令人信服嘅領袖',
    ('ENFJ', '8w9'): '你嘅影響力係來自包容而不是壓逼',
    ('ENFJ', '9w8'): '你和諧地帶領眾人，唔需要大聲宣示',
    ('ENFJ', '9w1'): '你創造嘅 community 係包容而有序嘅',

    ('ENFP', '1w9'): '你嘅理想主義帶住溫柔嘅堅持',
    ('ENFP', '1w2'): '你想用你嘅熱情去令世界更美好',
    ('ENFP', '2w1'): '你鼓勵人嘅方式溫暖又唔失原則',
    ('ENFP', '2w3'): '你嘅正能量感染人，仲要感染得好好睇',
    ('ENFP', '3w2'): '你唔止有夢想，仲有能力令 dreams happen',
    ('ENFP', '3w4'): '你嘅創意要有 originality，唔係 copycat',
    ('ENFP', '4w3'): '你嘅 imagination 係藝術級嘅，而且你 show off',
    ('ENFP', '4w5'): '你嘅內心世界五彩繽紛，係靈感嘅源頭',
    ('ENFP', '5w4'): '你對有興趣嘅 topic 可以 deep dive 到痴線',
    ('ENFP', '5w6'): '你探索世界時會做足功課，唔係亂嚟',
    ('ENFP', '6w5'): '你對新 idea 興奮但又會想太多，典型 ENFP',
    ('ENFP', '6w7'): '你帶俾人歡樂，但自己都需要安全感',
    ('ENFP', '7w6'): '你係 possibilities 嘅化身，冇嘢係唔可能',
    ('ENFP', '7w8'): '你嘅熱情係傳染病，人人都想跟你玩',
    ('ENFP', '8w7'): '你 free spirit 但又有強大嘅存在感',
    ('ENFP', '8w9'): '你隨和但唔好惹，內心有條底線',
    ('ENFP', '9w8'): '你 open-minded 但又有自己嘅堅持',
    ('ENFP', '9w1'): '你同乜人都玩得埋，但心中有價值觀',

    ('ISTJ', '1w9'): '你嘅辦事能力係頂級，仲要 zero error',
    ('ISTJ', '1w2'): '你做好本份之餘仲會幫人跟進',
    ('ISTJ', '2w1'): '你幫人有 system，唔係亂咁幫',
    ('ISTJ', '2w3'): '你幫人幫到令人覺得好可靠',
    ('ISTJ', '3w2'): '你嘅 efficiency 同 reliability 無人能及',
    ('ISTJ', '3w4'): '你做事有 quality，唔求快求靚',
    ('ISTJ', '4w3'): '你嘅工作有風格，係低調嘅專業',
    ('ISTJ', '4w5'): '你對細節嘅執著係一種藝術',
    ('ISTJ', '5w4'): '你對專業領域嘅知識有深度嘅追求',
    ('ISTJ', '5w6'): '你嘅 SOP 永遠係最新最完善嘅',
    ('ISTJ', '6w5'): '你係 team 入面最 reliable 嗰個',
    ('ISTJ', '6w7'): '你守規矩但唔死板，會靈活變通',
    ('ISTJ', '7w6'): '你鍾意穩定，但有時都會想試新嘢',
    ('ISTJ', '7w8'): '你做實事嘅效率驚人，又快又準',
    ('ISTJ', '8w7'): '你喺崗位上嘅 authority 係建立喺實力之上',
    ('ISTJ', '8w9'): '你 low key 但 powerful，係穩重嘅存在',
    ('ISTJ', '9w8'): '你平靜地處理一切，係團隊嘅定海神針',
    ('ISTJ', '9w1'): '你嘅 consistency 令人安心，係可敬嘅存在',

    ('ISFJ', '1w9'): '你照顧人照顧到無微不至，仲要有 quality',
    ('ISFJ', '1w2'): '你默默付出，而且付出得好有 dignity',
    ('ISFJ', '2w1'): '你嘅關懷有 boundary，係成熟嘅溫柔',
    ('ISFJ', '2w3'): '你照顧人總係喺最恰到好處嘅時候',
    ('ISFJ', '3w2'): '你嘅細心令人感動，但你唔覺得自己特別',
    ('ISFJ', '3w4'): '你關心人嘅方式好有個人風格',
    ('ISFJ', '4w3'): '你嘅溫柔帶住一點與別不同',
    ('ISFJ', '4w5'): '你靜靜咁理解每一個人，係最溫柔嘅 observer',
    ('ISFJ', '5w4'): '你對人嘅觀察力好敏銳，但你唔會講出口',
    ('ISFJ', '5w6'): '你 plan 好一切先行動，確保萬無一失',
    ('ISFJ', '6w5'): '你永遠係第一個發現邊個唔開心嘅人',
    ('ISFJ', '6w7'): '你令身邊人感到被 care 同 safe',
    ('ISFJ', '7w6'): '你溫柔又 playful，同你相處好舒服',
    ('ISFJ', '7w8'): '你照顧人時都有自己嘅主張同底氣',
    ('ISFJ', '8w7'): '你溫柔但唔軟弱，關鍵時候好有力量',
    ('ISFJ', '8w9'): '你嘅保護欲係溫柔而堅定嘅',
    ('ISFJ', '9w8'): '你隨和但 always there when needed',
    ('ISFJ', '9w1'): '你用溫柔去維持和諧，係暖心的存在',

    ('ESTJ', '1w9'): '你嘅執行力同標準一樣咁高',
    ('ESTJ', '1w2'): '你管理團隊唔止要效率，仲要人人有得著',
    ('ESTJ', '2w1'): '你帶人嘅方式係嚴格但有愛心',
    ('ESTJ', '2w3'): '你 manage 團隊時令人信服又有效率',
    ('ESTJ', '3w2'): '你嘅效率同人際技巧係完美組合',
    ('ESTJ', '3w4'): '你做事唔淨止快，仲要有 style',
    ('ESTJ', '4w3'): '你嘅管理風格有個人特色，唔係死板嘅',
    ('ESTJ', '4w5'): '你對系統嘅理解有 depth，唔係得個殼',
    ('ESTJ', '5w4'): '你管理時會用到深厚嘅專業知識',
    ('ESTJ', '5w6'): '你每一項 decision 都有 data support',
    ('ESTJ', '6w5'): '你確保一切運作正常，係可靠嘅舵手',
    ('ESTJ', '6w7'): '你有效率但唔 rigid，識得適應',
    ('ESTJ', '7w6'): '你 drive 團隊向前，同時確保 risk 可控',
    ('ESTJ', '7w8'): '你 push 起嚟冇人跟到，但你 deliver',
    ('ESTJ', '8w7'): '你天生係 leader，command respect',
    ('ESTJ', '8w9'): '你有 authority 但唔會 micromanage',
    ('ESTJ', '9w8'): '你 manage 團隊 calm 但有 force',
    ('ESTJ', '9w1'): '你建立嘅 system 係 fair 同 efficient 嘅',

    ('ESFJ', '1w9'): '你照顧社群嘅方式有條不紊，係成熟嘅關懷',
    ('ESFJ', '1w2'): '你幫人嘅時候有原則，唔係盲目順從',
    ('ESFJ', '2w1'): '你嘅慷慨有 boundary，係 healthy 嘅付出',
    ('ESFJ', '2w3'): '你係社群嘅 heart，人人都 feel welcome',
    ('ESFJ', '3w2'): '你 organise 活動嘅能力令人佩服',
    ('ESFJ', '3w4'): '你 care 人嘅方式好真摯，唔係做 show',
    ('ESFJ', '4w3'): '你嘅社交魅力帶一點獨特嘅氣質',
    ('ESFJ', '4w5'): '你對人際關係嘅 insight 好深',
    ('ESFJ', '5w4'): '你 understanding 人嘅方式既有 warmth 又有 depth',
    ('ESFJ', '5w6'): '你照顧人之前已經做好晒 research',
    ('ESFJ', '6w5'): '你係第一個注意到 group dynamics 嘅人',
    ('ESFJ', '6w7'): '你令成個 group feel connected 同 safe',
    ('ESFJ', '7w6'): '你帶動氣氛但不忘照顧每個人嘅需要',
    ('ESFJ', '7w8'): '你嘅 hospitality 係大膽又溫暖嘅',
    ('ESFJ', '8w7'): '你 protect 你嘅 people 時係好強勢嘅',
    ('ESFJ', '8w9'): '你嘅影響力來自真誠而非操控',
    ('ESFJ', '9w8'): '你隨和地 hold 住成個場面',
    ('ESFJ', '9w1'): '你用溫暖去建立和諧嘅社群',

    ('ISTP', '1w9'): '你動手做嘅嘢 zero defect，係工藝級',
    ('ISTP', '1w2'): '你嘅技能係用嚟幫人解決問題',
    ('ISTP', '2w1'): '你幫人整嘢時好有原則，唔會 hea',
    ('ISTP', '2w3'): '你默默出手幫人，瀟灑得嚟又好溫柔',
    ('ISTP', '3w2'): '你嘅 practical skills 令人驚嘆',
    ('ISTP', '3w4'): '你整嘅嘢又 functional 又有型',
    ('ISTP', '4w3'): '你嘅 craftsmanship 有個人 signature',
    ('ISTP', '4w5'): '你對 mechanics 嘅理解有藝術家嘅靈魂',
    ('ISTP', '5w4'): '你鑽研技術時有種禪意',
    ('ISTP', '5w6'): '你解決問題前已諗好所有 scenarios',
    ('ISTP', '6w5'): '你 troubleshooting 時冷靜又精準',
    ('ISTP', '6w7'): '你技術高超又靈活，乜都難唔到你',
    ('ISTP', '7w6'): '你鍾意玩 tech gadgets 同 practical 嘢',
    ('ISTP', '7w8'): '你改裝起嘢嚟大膽又精準',
    ('ISTP', '8w7'): '你操控工具嘅氣勢令人覺得你係專業',
    ('ISTP', '8w9'): '你 master 咗你嘅 craft，低調但強大',
    ('ISTP', '9w8'): '你平靜地做自己嘢，但出手就知有冇',
    ('ISTP', '9w1'): '你嘅 workflow 係順暢而精準嘅',

    ('ISFP', '1w9'): '你嘅美學標準好高，但係溫柔嘅完美',
    ('ISFP', '1w2'): '你嘅藝術係用來療癒人心嘅',
    ('ISFP', '2w1'): '你創作時心中有愛同原則',
    ('ISFP', '2w3'): '你嘅作品令人 feel touched',
    ('ISFP', '3w2'): '你嘅藝術才華令人眼前一亮',
    ('ISFP', '3w4'): '你嘅創作有 authentic 嘅風格',
    ('ISFP', '4w3'): '你嘅美感係天生嘅，仲要好有個人風格',
    ('ISFP', '4w5'): '你嘅作品反映咗你內心嘅深度',
    ('ISFP', '5w4'): '你對美嘅 understanding 有好深嘅思考',
    ('ISFP', '5w6'): '你創作前會做足 research，係認真嘅 artist',
    ('ISFP', '6w5'): '你透過藝術去理解同消化世界',
    ('ISFP', '6w7'): '你嘅創作 playful 但又 meaningful',
    ('ISFP', '7w6'): '你嘅 imagination 冇極限，乜媒材都玩',
    ('ISFP', '7w8'): '你嘅作品大膽又充滿生命力',
    ('ISFP', '8w7'): '你創作時好有 presence，作品有力量',
    ('ISFP', '8w9'): '你嘅藝術溫柔但有力',
    ('ISFP', '9w8'): '你隨心創作但作品自然有質素',
    ('ISFP', '9w1'): '你嘅創作係和諧同美感嘅結合',

    ('ESTP', '1w9'): '你行動力驚人，而且每一次都精準',
    ('ESTP', '1w2'): '你嘅行動係為咗創造價值俾人',
    ('ESTP', '2w1'): '你幫人有 action，唔係講嘢咁簡單',
    ('ESTP', '2w3'): '你出手幫人時總係恰到好處',
    ('ESTP', '3w2'): '你嘅 charisma 同行動力令人信服',
    ('ESTP', '3w4'): '你嘅行動有 style，唔係亂衝',
    ('ESTP', '4w3'): '你嘅膽識同品味係迷人嘅組合',
    ('ESTP', '4w5'): '你嘅行動背後有 strategy',
    ('ESTP', '5w4'): '你行動前已經 mentally 模擬過好多次',
    ('ESTP', '5w6'): '你冒險時有 plan B 同 plan C',
    ('ESTP', '6w5'): '你反應快又謹慎，係生存高手',
    ('ESTP', '6w7'): '你大膽但會諗過度過，係精明嘅冒險家',
    ('ESTP', '7w6'): '你永遠準備好下一個 adventure',
    ('ESTP', '7w8'): '你 push boundaries 而且唔驚人地',
    ('ESTP', '8w7'): '你嘅 presence 同 energy 主宰全場',
    ('ESTP', '8w9'): '你有 power 但識得收放自如',
    ('ESTP', '9w8'): '你 chill 但一出手就知龍與鳳',
    ('ESTP', '9w1'): '你行動時有自己嘅 code，瀟灑但正直',

    ('ESFP', '1w9'): '你帶歡樂俾人，仲要帶得有 quality',
    ('ESFP', '1w2'): '你令人開心嘅方式係溫暖而真摯嘅',
    ('ESFP', '2w1'): '你對人好但唔會 lost yourself',
    ('ESFP', '2w3'): '你令人 feel special，係你嘅天賦',
    ('ESFP', '3w2'): '你表演時嘅感染力係天生嘅 entertainer',
    ('ESFP', '3w4'): '你嘅演出有 authenticity 同 depth',
    ('ESFP', '4w3'): '你嘅 star quality 同獨特魅力冇得輸',
    ('ESFP', '4w5'): '你快樂嘅外表下有豐富嘅內心世界',
    ('ESFP', '5w4'): '你對享受 life 嘅學問有深度研究',
    ('ESFP', '5w6'): '你玩之前會做好 research，係精明玩家',
    ('ESFP', '6w5'): '你帶動氣氛但同時感知到 each vibe',
    ('ESFP', '6w7'): '你令每一刻都係 celebration',
    ('ESFP', '7w6'): '你係 life of the party，但都 reliable',
    ('ESFP', '7w8'): '你玩得最盡最大，live life to the fullest',
    ('ESFP', '8w7'): '你嘅 energy 同魅力係 magnetic',
    ('ESFP', '8w9'): '你 enjoy life 但有自己嘅界線',
    ('ESFP', '9w8'): '你 chill 同 fun 嘅 vibe 令人想親近',
    ('ESFP', '9w1'): '你帶俾人歡樂嘅同時蘊藏 wisdom',
}

# ── All 288 encourages ──────────────────────────────────────────────
ENCOURAGES = {
    ('INTJ', '1w9'): '你嘅標準係高，但要記得人性唔係 code，唔可以完全 predict',
    ('INTJ', '1w2'): '你幫人係好事，但唔好將自己嘅標準強加俾人',
    ('INTJ', '2w1'): '你嘅付出好有原則，但要記得接受別人不完美',
    ('INTJ', '2w3'): '你幫人時有 expectation 好正常，但都要放過自己',
    ('INTJ', '3w2'): '你嘅野心同魅力係資產，但都要停低感受下',
    ('INTJ', '3w4'): '你嘅成就同深度並存，但唔好活喺比較之中',
    ('INTJ', '4w3'): '你與眾不同係優點，但唔需要證明俾全世界睇',
    ('INTJ', '4w5'): '你嘅深度係天賦，但要 connect with people 先完整',
    ('INTJ', '5w4'): '你嘅知識好珍貴，但有時實踐比理論重要',
    ('INTJ', '5w6'): '你 prepare 得夠晒，係時候行動了',
    ('INTJ', '6w5'): '你嘅分析好透徹，但要信自己嘅判斷',
    ('INTJ', '6w7'): '你嘅謹慎同好奇心可以並存，唔使二揀一',
    ('INTJ', '7w6'): '你嘅 vision 好宏大，但要 focus 先可以實現',
    ('INTJ', '7w8'): '你嘅野心係 fuel，但都要顧吓身邊人',
    ('INTJ', '8w7'): '你嘅力量係天賦，但 vulnerability 都係一種力量',
    ('INTJ', '8w9'): '你強大得嚟平和，呢個係最好嘅狀態',
    ('INTJ', '9w8'): '你嘅平靜係力量，但都要適時表達立場',
    ('INTJ', '9w1'): '你追求和諧係美德，但都要 keep 住 authenticity',

    ('INTP', '1w9'): '你嘅理論可以完美，但現實世界有佢嘅 logic',
    ('INTP', '1w2'): '你嘅知識可以改變世界，但要 connect with people',
    ('INTP', '2w1'): '你 share 知識時可以 warm 啲，唔使永遠 detached',
    ('INTP', '2w3'): '你嘅聰明值得被看見，唔好收收埋埋',
    ('INTP', '3w2'): '你嘅才華係真嘅，唔使扮低調',
    ('INTP', '3w4'): '你嘅 ideas 有 depth，值得俾更多人 know',
    ('INTP', '4w3'): '你嘅原創性係禮物，唔好收埋',
    ('INTP', '4w5'): '你嘅思想迷宮好精彩，但都要定時出嚟呼吸',
    ('INTP', '5w4'): '你嘅求知慾係 gift，但唔好忘記生活',
    ('INTP', '5w6'): '你嘅 system 好完善，但要記得 test in reality',
    ('INTP', '6w5'): '你嘅質疑精神好重要，但都要信自己一次',
    ('INTP', '6w7'): '你嘅好奇心係寶藏，唔好俾恐懼限制',
    ('INTP', '7w6'): '你乜都想學係好事，但 depth over breadth 都重要',
    ('INTP', '7w8'): '你嘅 intellect 係武器，但温柔都係一種力量',
    ('INTP', '8w7'): '你嘅智力自信係好事，但要俾空間俾人',
    ('INTP', '8w9'): '你選擇 battles 嘅智慧好成熟',
    ('INTP', '9w8'): '你嘅 ideas 值得出聲，唔好永遠做觀察者',
    ('INTP', '9w1'): '你嘅分析力係天賦，但都要 trust your gut',

    ('ENTJ', '1w9'): '你嘅標準成就 greatness，但要包容人性嘅 imperfection',
    ('ENTJ', '1w2'): '你帶領團隊時 tight 得嚟都要有 compassion',
    ('ENTJ', '2w1'): '你幫助團隊成長係美德，但要俾人犯错',
    ('ENTJ', '2w3'): '你嘅 leadership 令人欽佩，但要留時間俾自己',
    ('ENTJ', '3w2'): '你嘅成就令人 respect，但 process 同結果一樣重要',
    ('ENTJ', '3w4'): '你追求卓越係好事，但唔好活喺 hustle culture 入面',
    ('ENTJ', '4w3'): '你嘅獨特領導風格係資產，唔好懷疑自己',
    ('ENTJ', '4w5'): '你嘅 vision 有 depth，係好珍貴嘅',
    ('ENTJ', '5w4'): '你嘅智慧領導係禮物，但都要 listen to 直覺',
    ('ENTJ', '5w6'): '你嘅策略完美，但要留空間俾 spontaneity',
    ('ENTJ', '6w5'): '你嘅準備功夫充足，但要信自己可以 handle',
    ('ENTJ', '6w7'): '你大膽又謹慎，係最好嘅組合',
    ('ENTJ', '7w6'): '你嘅 plan 好宏大，但 execution 先係關鍵',
    ('ENTJ', '7w8'): '你嘅野心冇邊際，但要照顧好自己先',
    ('ENTJ', '8w7'): '你嘅 power 係天生嘅，但 kindness 先係真正嘅 strength',
    ('ENTJ', '8w9'): '你嘅權威唔需要 prove，calm confidence 就夠',
    ('ENTJ', '9w8'): '你 calm leadership 係成熟嘅表現',
    ('ENTJ', '9w1'): '你帶領團隊和諧進步，呢個係最好嘅 legacy',

    ('ENTP', '1w9'): '你嘅 argument 好 sharp，但有時 listening 比 debating 重要',
    ('ENTP', '1w2'): '你 challenge 人係為咗成長，但都要有同理心',
    ('ENTP', '2w1'): '你 debate 時可以 warm 啲，唔使永遠做 devil advocate',
    ('ENTP', '2w3'): '你嘅 ideas 好精彩，但都要有 follow-through',
    ('ENTP', '3w2'): '你贏得 debates，但 relationships 唔係要贏嘅',
    ('ENTP', '3w4'): '你嘅 originality 係寶藏，但都要接受平凡嘅 moment',
    ('ENTP', '4w3'): '你嘅創意無限，但要 focus 完成一個先',
    ('ENTP', '4w5'): '你嘅 deep dive 好正，但都要浮上水面透氣',
    ('ENTP', '5w4'): '你嘅知識廣博，但要 share 多啲俾世界',
    ('ENTP', '5w6'): '你嘅準備好充足，係時候跳出去試',
    ('ENTP', '6w5'): '你嘅 critical thinking 係武器，但都要信人',
    ('ENTP', '6w7'): '你嘅 adaptability 係 superpower',
    ('ENTP', '7w6'): '你嘅 idea factory 好勁，但要 pick 一個做先',
    ('ENTP', '7w8'): '你大膽探索係好事，但都要考慮 consequences',
    ('ENTP', '8w7'): '你嘅 debating 氣場好強，但都要俾 space 人哋',
    ('ENTP', '8w9'): '你選擇性出手係智慧嘅表現',
    ('ENTP', '9w8'): '你睇到好多 possibilities，但都要 commit 一個',
    ('ENTP', '9w1'): '你嘅 intellectual 彈性係禮物，但要站穩立場',

    ('INFJ', '1w9'): '你嘅理想世界好美好，但現實都有佢嘅 beauty',
    ('INFJ', '1w2'): '你改變世界嘅熱情好珍貴，但要由照顧自己開始',
    ('INFJ', '2w1'): '你嘅付出係愛嘅表現，但都要接受自己嘅 need',
    ('INFJ', '2w3'): '你照顧所有人係美德，但要 remember yourself',
    ('INFJ', '3w2'): '你對世界嘅 impact 係真嘅，但你本來 already enough',
    ('INFJ', '3w4'): '你嘅使命感好強，但都要 enjoy 當下',
    ('INFJ', '4w3'): '你被明白嘅渴望好正常，你值得被 see',
    ('INFJ', '4w5'): '你嘅深度係天賦，但要 connect 先可以療癒',
    ('INFJ', '5w4'): '你嘅 insight 好珍貴，但要 share 出嚟',
    ('INFJ', '5w6'): '你嘅 vision 同 planning 係完美組合',
    ('INFJ', '6w5'): '你嘅 intuition 好準，要信多啲自己',
    ('INFJ', '6w7'): '你嘅敏感同樂觀可以 coexist',
    ('INFJ', '7w6'): '你嘅想像力係 gift，但都要有 solid plan',
    ('INFJ', '7w8'): '你嘅 vision 大到可以 changed the world',
    ('INFJ', '8w7'): '你嘅溫柔力量係世上最強大嘅嘢',
    ('INFJ', '8w9'): '你嘅 peacekeeping 能力係 trade，但要守好自己',
    ('INFJ', '9w8'): '你嘅 calm 係力量，但要表達自己嘅 need',
    ('INFJ', '9w1'): '你建立和諧嘅能力係天賦，但要 keep 自己嘅 voice',

    ('INFP', '1w9'): '你嘅內心世界好純粹，但世界都值得你參與',
    ('INFP', '1w2'): '你為世界帶嚟美好係你嘅使命',
    ('INFP', '2w1'): '你嘅善良有原則，係最 healthy 嘅付出',
    ('INFP', '2w3'): '你值得被欣賞，唔好覺得自己唔重要',
    ('INFP', '3w2'): '你嘅才華值得被 seen，唔好收埋',
    ('INFP', '3w4'): '你嘅創作係 authentic，呢個係最珍貴嘅',
    ('INFP', '4w3'): '你嘅 uniqueness 係禮物，唔需要 justify',
    ('INFP', '4w5'): '你內心嘅宇宙好豐富，但要 connect with others',
    ('INFP', '5w4'): '你嘅情感深度係藝術嘅源頭',
    ('INFP', '5w6'): '你嘅故事同 symbols 可以 healing 好多人',
    ('INFP', '6w5'): '你嘅敏感係 superpower，唔係負擔',
    ('INFP', '6w7'): '你喺夢想同現實之間可以找到 balance',
    ('INFP', '7w6'): '你嘅想像力無限，但都要有 action',
    ('INFP', '7w8'): '你 explore 黑暗係為咗 find light',
    ('INFP', '8w7'): '你溫柔下有 backbone，呢個係最好嘅你',
    ('INFP', '8w9'): '你 protect 自己嘅價值係啱嘅',
    ('INFP', '9w8'): '你嘅 flexibility 係禮物，但都要 set boundaries',
    ('INFP', '9w1'): '你嘅 inner peace 係力量嘅來源',

    ('ENFJ', '1w9'): '你 inspire people 嘅能力係 gift，但都要 recharge',
    ('ENFJ', '1w2'): '你帶領人成長係 mission，但要俾人自己行',
    ('ENFJ', '2w1'): '你嘅關懷有 boundary 係成熟嘅愛',
    ('ENFJ', '2w3'): '你嘅付出令世界更好，但都要收吓禮物',
    ('ENFJ', '3w2'): '你嘅影響力係真嘅，但你本身就已經好夠',
    ('ENFJ', '3w4'): '你嘅 leadership 有深度，值得被 respect',
    ('ENFJ', '4w3'): '你令每個人 feel seen 係你嘅 superpower',
    ('ENFJ', '4w5'): '你嘅人性 insight 係天賦，要信自己',
    ('ENFJ', '5w4'): '你嘅 wisdom 同 warmth 係罕見嘅組合',
    ('ENFJ', '5w6'): '你嘅 vision 加 plan 係不可阻擋嘅',
    ('ENFJ', '6w5'): '你對人嘅 care 同 preparedness 令人安心',
    ('ENFJ', '6w7'): '你嘅 positivity 同 care 係最好嘅禮物',
    ('ENFJ', '7w6'): '你嘅 energy 係感染力，但都要俾自己 rest',
    ('ENFJ', '7w8'): '你嘅 passion 係 contagious，continue inspiring',
    ('ENFJ', '8w7'): '你嘅溫柔同力量結合係最 powerful 嘅',
    ('ENFJ', '8w9'): '你嘅 inclusive leadership 係榜樣',
    ('ENFJ', '9w8'): '你 calm 咁帶領眾人係一種藝術',
    ('ENFJ', '9w1'): '你創造嘅和諧 community 係你嘅 legacy',

    ('ENFP', '1w9'): '你嘅理想主義係 beautiful，但要接受現實嘅 messiness',
    ('ENFP', '1w2'): '你嘅熱情同善意可以 change the world',
    ('ENFP', '2w1'): '你鼓勵人嘅方式係 gift，但要記得自己都需要 support',
    ('ENFP', '2w3'): '你嘅正能量係 contagious，keep shining',
    ('ENFP', '3w2'): '你嘅 dreams 加上你嘅魅力可以 achieve anything',
    ('ENFP', '3w4'): '你嘅 originality 係最珍貴嘅嘢',
    ('ENFP', '4w3'): '你嘅 imagination 係無限嘅，share it with the world',
    ('ENFP', '4w5'): '你內在世界嘅 richness 係靈感嘅來源',
    ('ENFP', '5w4'): '你嘅 curiosity 係 treasure，keep exploring',
    ('ENFP', '5w6'): '你嘅探索精神加 preparation 係無敵',
    ('ENFP', '6w5'): '你嘅 excitement 同 depth 係獨一無二嘅',
    ('ENFP', '6w7'): '你帶俾人 joy，但都要俾自己 stability',
    ('ENFP', '7w6'): '你嘅 possibilities mindset 係 superpower',
    ('ENFP', '7w8'): '你嘅 free spirit 係 contagious，fly high',
    ('ENFP', '8w7'): '你嘅 presence 同 energy 係 magnetic',
    ('ENFP', '8w9'): '你隨和但 powerful，呢個係最好嘅你',
    ('ENFP', '9w8'): '你嘅 open mind 係禮物，但都要有 own voice',
    ('ENFP', '9w1'): '你 connect 到所有人嘅能力係天賦',

    ('ISTJ', '1w9'): '你嘅穩定性係團隊嘅基石，但都要適時放鬆',
    ('ISTJ', '1w2'): '你嘅責任感令人敬佩，但要分啲俾人',
    ('ISTJ', '2w1'): '你幫人有 system 係好事，但都要靈活',
    ('ISTJ', '2w3'): '你嘅可靠性係 gift，唔好攰親自己',
    ('ISTJ', '3w2'): '你嘅 efficiency 同 care 係完美組合',
    ('ISTJ', '3w4'): '你嘅 quality 標準係值得 respect',
    ('ISTJ', '4w3'): '你嘅專業 style 係你嘅 signature',
    ('ISTJ', '4w5'): '你對細節嘅關注係一種藝術',
    ('ISTJ', '5w4'): '你嘅專業 depth 係好珍貴嘅',
    ('ISTJ', '5w6'): '你嘅 SOP 係 masterpiece，但要留 space 給 創新',
    ('ISTJ', '6w5'): '你嘅 reliability 係 team 嘅 backbone',
    ('ISTJ', '6w7'): '你守規矩但唔死板，呢個係最好嘅 balance',
    ('ISTJ', '7w6'): '你嘅穩定性加上 flexibility 係 superpower',
    ('ISTJ', '7w8'): '你嘅 efficiency 同 decisiveness 令人佩服',
    ('ISTJ', '8w7'): '你嘅 competence 係你嘅 authority',
    ('ISTJ', '8w9'): '你嘅 low key power 係成熟嘅表現',
    ('ISTJ', '9w8'): '你 calm 嘅 presence 係團隊嘅定心丸',
    ('ISTJ', '9w1'): '你嘅 consistency 係你嘅 superpower',

    ('ISFJ', '1w9'): '你嘅溫柔照顧係 gift，但都要俾人照顧你',
    ('ISFJ', '1w2'): '你默默付出係愛嘅表現，你值得被看見',
    ('ISFJ', '2w1'): '你嘅 care 有 boundary 係最 healthy 嘅',
    ('ISFJ', '2w3'): '你嘅細心令人感動，你係 irreplaceable 嘅',
    ('ISFJ', '3w2'): '你嘅體貼係最有力量嘅嘢',
    ('ISFJ', '3w4'): '你關心人嘅方式好 unique，keep being you',
    ('ISFJ', '4w3'): '你嘅溫柔帶著與別不同，呢個係你嘅 charm',
    ('ISFJ', '4w5'): '你觀察人性嘅能力係 gift',
    ('ISFJ', '5w4'): '你對人嘅 understanding 好深，share more',
    ('ISFJ', '5w6'): '你嘅 preparedness 令人安心',
    ('ISFJ', '6w5'): '你嘅 sensitivity 係 superpower',
    ('ISFJ', '6w7'): '你令身邊人 feel safe 係最珍貴嘅',
    ('ISFJ', '7w6'): '你嘅溫柔同 playful 嘅 balance 係完美',
    ('ISFJ', '7w8'): '你嘅 care 有 backbone，呢個係成熟',
    ('ISFJ', '8w7'): '你溫柔但 powerful 係最好嘅 combination',
    ('ISFJ', '8w9'): '你嘅 protective 係愛嘅表現',
    ('ISFJ', '9w8'): '你隨和但 always there，呢個係你嘅 superpower',
    ('ISFJ', '9w1'): '你嘅 peaceful presence 係禮物',

    ('ESTJ', '1w9'): '你嘅 standard 係高咗啲，但要記住人唔係 machine',
    ('ESTJ', '1w2'): '你嘅 leadership 有 heart，呢個係最好嘅組合',
    ('ESTJ', '2w1'): '你嚴格得嚟有愛心，員工會 respect 你',
    ('ESTJ', '2w3'): '你 manage 又好又靚，係榜樣',
    ('ESTJ', '3w2'): '你嘅 efficiency 同 people skills 係無敵',
    ('ESTJ', '3w4'): '你嘅執行力有 style，係你嘅 trademark',
    ('ESTJ', '4w3'): '你嘅管理風格有個人 signature',
    ('ESTJ', '4w5'): '你對 system 嘅理解有 depth',
    ('ESTJ', '5w4'): '你嘅 knowledge 加 decision 係 powerful',
    ('ESTJ', '5w6'): '你嘅 data-driven leadership 係好嘢',
    ('ESTJ', '6w5'): '你嘅 reliability 係團隊嘅 foundation',
    ('ESTJ', '6w7'): '你嘅 efficiency 同 adaptability 係 perfect',
    ('ESTJ', '7w6'): '你嘅 drive 同 caution 係 winning combo',
    ('ESTJ', '7w8'): '你嘅 push 同 delivery 係 legendary',
    ('ESTJ', '8w7'): '你天生係 leader，inspire 身邊人',
    ('ESTJ', '8w9'): '你 authority 得嚟 calm，係最高境界',
    ('ESTJ', '9w8'): '你 calm 嘅 authority 令人信服',
    ('ESTJ', '9w1'): '你建立嘅 system 係 fair 同 efficient',

    ('ESFJ', '1w9'): '你照顧人嘅方式好有 quality，但都要照顧自己',
    ('ESFJ', '1w2'): '你嘅社群精神係 inspring，continue your good work',
    ('ESFJ', '2w1'): '你嘅 care 有 boundary 係 healthy',
    ('ESFJ', '2w3'): '你令身邊人 feel welcome 係你嘅 superpower',
    ('ESFJ', '3w2'): '你嘅 organisation 同 warmth 係 best combo',
    ('ESFJ', '3w4'): '你嘅真摯關懷係最有價值嘅嘢',
    ('ESFJ', '4w3'): '你嘅獨特社交魅力係你嘅 signature',
    ('ESFJ', '4w5'): '你對人際關係嘅 insight 好珍貴',
    ('ESFJ', '5w4'): '你嘅 understanding 加 warmth 係 rare gift',
    ('ESFJ', '5w6'): '你嘅 preparedness 同 care 令人安心',
    ('ESFJ', '6w5'): '你嘅 group awareness 係天賦',
    ('ESFJ', '6w7'): '你令 group feel connected 係你最叻嘅嘢',
    ('ESFJ', '7w6'): '你帶動氣氛不忘照顧每個人，呢個係 mature',
    ('ESFJ', '7w8'): '你嘅 hospitality 同 energy 係 contagious',
    ('ESFJ', '8w7'): '你 protect 你嘅 people 係你嘅 strength',
    ('ESFJ', '8w9'): '你嘅 genuine influence 係 most powerful 嘅',
    ('ESFJ', '9w8'): '你 chill 咁 hold 住全場，係一種藝術',
    ('ESFJ', '9w1'): '你建立嘅和諧社群係你嘅 legacy',

    ('ISTP', '1w9'): '你嘅手藝係 perfection，但都要 showcase 俾人睇',
    ('ISTP', '1w2'): '你嘅 skill 係為咗 help people，呢個係高尚',
    ('ISTP', '2w1'): '你幫人時可以 warm 啲，唔使永遠 stoic',
    ('ISTP', '2w3'): '你嘅 silent help 係最溫柔嘅付出',
    ('ISTP', '3w2'): '你嘅 practical genius 值得被 respect',
    ('ISTP', '3w4'): '你嘅 craft 有 art 嘅元素，keep creating',
    ('ISTP', '4w3'): '你嘅手藝有 signature，係你嘅 style',
    ('ISTP', '4w5'): '你對 mechanics 嘅理解有深度',
    ('ISTP', '5w4'): '你嘅 craftsmanship 係一種 meditation',
    ('ISTP', '5w6'): '你嘅 problem solving 係 masterpiece',
    ('ISTP', '6w5'): '你 troubleshooting 時係最 calm 嘅 genius',
    ('ISTP', '6w7'): '你嘅 skill 同 flexibility 係 superpower',
    ('ISTP', '7w6'): '你玩 tech 嘅 passion 係 contagious',
    ('ISTP', '7w8'): '你改裝起來膽大心細，係 expert',
    ('ISTP', '8w7'): '你嘅 command 喺工具領域係無敵',
    ('ISTP', '8w9'): '你 master craft 嘅低調係最型嘅',
    ('ISTP', '9w8'): '你 calm 嘅 competence 係最型嘅',
    ('ISTP', '9w1'): '你嘅 workflow 係 perfect balance',

    ('ISFP', '1w9'): '你嘅美學追求係 gift，但都要俾人睇到你嘅作品',
    ('ISFP', '1w2'): '你嘅藝術有治癒力量，share it with the world',
    ('ISFP', '2w1'): '你創作時心中有愛，呢個 shines through',
    ('ISFP', '2w3'): '你嘅作品 touch 人心，唔好收埋',
    ('ISFP', '3w2'): '你嘅 talent 值得被 seen 同 celebrated',
    ('ISFP', '3w4'): '你嘅 authentic style 係最好嘅 signature',
    ('ISFP', '4w3'): '你嘅獨特美感係你最 powerful 嘅嘢',
    ('ISFP', '4w5'): '你嘅 depth 係藝術嘅 soul',
    ('ISFP', '5w4'): '你嘅 creative depth 係 rare 嘅 gift',
    ('ISFP', '5w6'): '你嘅 artistic research 令你嘅作品更 solid',
    ('ISFP', '6w5'): '你透過 art 理解世界係你嘅 way',
    ('ISFP', '6w7'): '你嘅 playful 創作係最自由嘅表達',
    ('ISFP', '7w6'): '你嘅 imagination 冇 limit，keep playing',
    ('ISFP', '7w8'): '你嘅藝術大膽又自由，係 inspiring',
    ('ISFP', '8w7'): '你創作時嘅 presence 係 powerful',
    ('ISFP', '8w9'): '你嘅 gentle power 喺藝術中 shine',
    ('ISFP', '9w8'): '你隨心創作嘅自然美感係 gift',
    ('ISFP', '9w1'): '你嘅 art 係 harmony 同 beauty 嘅結合',

    ('ESTP', '1w9'): '你嘅行動力加精準度係 deadly combo',
    ('ESTP', '1w2'): '你嘅 action 係為咗 create value，keep going',
    ('ESTP', '2w1'): '你幫人有 action，係最直接嘅善良',
    ('ESTP', '2w3'): '你出手幫人嘅 style 係你嘅 charm',
    ('ESTP', '3w2'): '你嘅 charisma 同 drive 係 magnetic',
    ('ESTP', '3w4'): '你嘅行動有 style，係你嘅 signature',
    ('ESTP', '4w3'): '你嘅膽識同品味係迷人組合',
    ('ESTP', '4w5'): '你嘅 action 背後有 depth，令你更 powerful',
    ('ESTP', '5w4'): '你嘅 mental rehearsal 係你嘅 secret weapon',
    ('ESTP', '5w6'): '你冒險有 plan，係精明嘅 risk taker',
    ('ESTP', '6w5'): '你嘅 quick reaction 同 caution 係生存智慧',
    ('ESTP', '6w7'): '你大膽又精明，係最成功嘅冒險家',
    ('ESTP', '7w6'): '你永遠準備好下一個 adventure，live your best life',
    ('ESTP', '7w8'): '你 push boundaries 嘅勇氣係 inspiring',
    ('ESTP', '8w7'): '你嘅 energy 同 presence 係 unstoppable',
    ('ESTP', '8w9'): '你嘅 power 同 restraint 係成熟嘅象徵',
    ('ESTP', '9w8'): '你 chill 但 powerful，呢個係最型嘅',
    ('ESTP', '9w1'): '你行動有 code，係瀟灑嘅正直',

    ('ESFP', '1w9'): '你帶俾人嘅快樂有 quality，keep shining',
    ('ESFP', '1w2'): '你嘅 warmth 同 joy 係 healing',
    ('ESFP', '2w1'): '你對人好不忘自己，呢個係 healthy',
    ('ESFP', '2w3'): '你令 each person feel special 係你嘅 superpower',
    ('ESFP', '3w2'): '你嘅 entertainment 係天生嘅 talent',
    ('ESFP', '3w4'): '你嘅演出有 depth，係你嘅 signature',
    ('ESFP', '4w3'): '你嘅 star quality 係 undeniable',
    ('ESFP', '4w5'): '你嘅內心世界同外向 charm 係 beautiful combo',
    ('ESFP', '5w4'): '你對生活 enjoying 嘅研究係深度',
    ('ESFP', '5w6'): '你 play hard 嘅背後有 smart preparation',
    ('ESFP', '6w5'): '你感知 vibes 嘅能力係 gift',
    ('ESFP', '6w7'): '你令每一刻都係 celebration，繼續 shine',
    ('ESFP', '7w6'): '你係 life of the party 但 reliable，best combo',
    ('ESFP', '7w8'): '你 live life to the fullest，inspire us all',
    ('ESFP', '8w7'): '你嘅 magnetic energy 係 gift',
    ('ESFP', '8w9'): '你 enjoy life 有 boundaries，係 mature 嘅 fun',
    ('ESFP', '9w8'): '你 chill 同 fun 嘅 vibe 係最吸引人嘅',
    ('ESFP', '9w1'): '你嘅 joy 同 wisdom 係 perfect balance',
}


def generate_entry(mbti, enneagram):
    """Format a single PersonalityName entry as Dart code."""
    emoji = MBTI_BASE[mbti]['emoji']
    name_canto = generate_name_canto(mbti, enneagram)
    tagline = TAGLINES[(mbti, enneagram)]
    encourage = ENCOURAGES[(mbti, enneagram)]

    key = f"'{mbti}_{enneagram}'"
    return f"""    {key}: PersonalityName(
      mbti: '{mbti}', enneagram: '{enneagram}', healthLevel: 'healthy',
      nameCanto: '{emoji} {name_canto}',
      tagline: '{tagline}',
      encourage: '{encourage}',
      emoji: '{emoji}',
    ),"""


def main():
    mbti_order = [
        'ENFJ', 'ENFP', 'ENTJ', 'ENTP',
        'ESFJ', 'ESFP', 'ESTJ', 'ESTP',
        'INFJ', 'INFP', 'INTJ', 'INTP',
        'ISFJ', 'ISFP', 'ISTJ', 'ISTP',
    ]
    enneagram_order = [
        '1w9', '1w2', '2w1', '2w3', '3w2', '3w4',
        '4w3', '4w5', '5w4', '5w6', '6w5', '6w7',
        '7w6', '7w8', '8w7', '8w9', '9w8', '9w1',
    ]

    # Generate only entries NOT in EXISTING_KEYS (skip the 16 originals)
    new_entries = []
    for mbti in mbti_order:
        for en in enneagram_order:
            key = f'{mbti}_{en}'
            if key not in EXISTING_KEYS:
                new_entries.append(generate_entry(mbti, en))

    all_new = '\n'.join(new_entries)
    print(f"New entries generated: {len(new_entries)}")
    print(f"Preserved originals: {len(EXISTING_KEYS)}")
    print(f"Total (with originals): {len(new_entries) + len(EXISTING_KEYS)}")

    # Preserved original entries (Phase 1)
    existing_entries = textwrap.dedent("""\
    'ENFJ_5w4': PersonalityName(
      mbti: 'ENFJ', enneagram: '5w4', healthLevel: 'healthy',
      nameCanto: '高級KAM L',
      tagline: '你睇到人哋睇唔到嘅 pattern，但唔好收埋自己',
      encourage: '你嘅觀察力係天賦，唔係詛咒',
      emoji: '🧠',
    ),

    'ENFP_7w4': PersonalityName(
      mbti: 'ENFP', enneagram: '7w4', healthLevel: 'healthy',
      nameCanto: '靈感噴泉',
      tagline: '你個腦永遠有新 idea，但都要記得落地',
      encourage: '你嘅創造力係禮物，但都要休息',
      emoji: '🌈',
    ),

    'ENTJ_8w7': PersonalityName(
      mbti: 'ENTJ', enneagram: '8w7', healthLevel: 'healthy',
      nameCanto: '自然領袖',
      tagline: '你唔使大聲都有人跟，因為你值得',
      encourage: '你嘅 vision 係力量，但要記得聆聽',
      emoji: '👑',
    ),

    'ENTP_7w6': PersonalityName(
      mbti: 'ENTP', enneagram: '7w6', healthLevel: 'healthy',
      nameCanto: '辯論機器',
      tagline: '你同空氣都可以拗一餐，但你其實想被明白',
      encourage: '你嘅聰明係禮物，唔好再用嚟激嬲人',
      emoji: '🔥',
    ),

    'ESFJ_2w3': PersonalityName(
      mbti: 'ESFJ', enneagram: '2w3', healthLevel: 'healthy',
      nameCanto: '社區組長',
      tagline: '你搞掂晒所有人嘅事，但自己嗰份呢？',
      encourage: '你值得被照顧，唔好成日淨係照顧人',
      emoji: '🤝',
    ),

    'ESFP_7w6': PersonalityName(
      mbti: 'ESFP', enneagram: '7w6', healthLevel: 'healthy',
      nameCanto: '派對心臟',
      tagline: '你有你喺度就唔會悶，但都要留時間俾自己',
      encourage: '你嘅快樂係感染性嘅，但都要俾自己喊',
      emoji: '🎉',
    ),

    'ESTJ_1w2': PersonalityName(
      mbti: 'ESTJ', enneagram: '1w2', healthLevel: 'healthy',
      nameCanto: '人類閘機',
      tagline: '你把關嚴格到過海關都驚你，但係因為你負責任',
      encourage: '你嘅標準係高，但要記得人都會犯錯',
      emoji: '📋',
    ),

    'ESTP_7w8': PersonalityName(
      mbti: 'ESTP', enneagram: '7w8', healthLevel: 'healthy',
      nameCanto: '行動先鋒',
      tagline: '你諗都唔諗就衝咗出去，有時係好事嚟㗎',
      encourage: '你嘅勇氣係天賦，但都要諗一諗先',
      emoji: '🎯',
    ),

    'INFJ_4w5': PersonalityName(
      mbti: 'INFJ', enneagram: '4w5', healthLevel: 'healthy',
      nameCanto: '靈魂解讀者',
      tagline: '你未出聲佢已經知道你諗咩，但你對自己最陌生',
      encourage: '你嘅直覺係超能力，但都要信自己多啲',
      emoji: '🔮',
    ),

    'INFP_4w5': PersonalityName(
      mbti: 'INFP', enneagram: '4w5', healthLevel: 'healthy',
      nameCanto: '深夜文青',
      tagline: '你嘅內心世界比宇宙仲大，但有時要出嚟透氣',
      encourage: '你嘅情感係深度，唔好覺得自己太敏感',
      emoji: '🌙',
    ),

    'INTJ_5w6': PersonalityName(
      mbti: 'INTJ', enneagram: '5w6', healthLevel: 'healthy',
      nameCanto: '密室策劃師',
      tagline: '你已經諗好未來十年嘅 plan A 到 plan D',
      encourage: '你嘅策略係天賦，但有時都要信個 flow',
      emoji: '♟️',
    ),

    'INTP_5w6': PersonalityName(
      mbti: 'INTP', enneagram: '5w6', healthLevel: 'healthy',
      nameCanto: '理論工程師',
      tagline: '你個腦永遠喺度 build system，但記得食飯',
      encourage: '你嘅分析力係禮物，但都要落地',
      emoji: '⚙️',
    ),

    'ISFJ_9w1': PersonalityName(
      mbti: 'ISFJ', enneagram: '9w1', healthLevel: 'healthy',
      nameCanto: '人肉暖爐',
      tagline: '你靜靜雞照顧晒所有人，但你以為冇人發現',
      encourage: '你嘅溫柔係超級力量，唔好覺得理所當然',
      emoji: '🏡',
    ),

    'ISFP_9w8': PersonalityName(
      mbti: 'ISFP', enneagram: '9w8', healthLevel: 'healthy',
      nameCanto: '低調藝術家',
      tagline: '你嘅作品代表一切，但你唔鍾意出聲',
      encourage: '你嘅美感係天賦，試下多啲俾人睇你嘅作品',
      emoji: '🎨',
    ),

    'ISTJ_1w9': PersonalityName(
      mbti: 'ISTJ', enneagram: '1w9', healthLevel: 'healthy',
      nameCanto: '可靠支柱',
      tagline: '你永遠係最穩陣嗰個，但有時都要放鬆下',
      encourage: '你嘅可靠性係 your superpower，但都要適時放手',
      emoji: '⚖️',
    ),

    'ISTP_5w6': PersonalityName(
      mbti: 'ISTP', enneagram: '5w6', healthLevel: 'healthy',
      nameCanto: '沉默工匠',
      tagline: '你動手做嘅嘢永遠比把口講嘅多',
      encourage: '你嘅手藝係才華，但都要試下講出嚟',
      emoji: '🔧',
    ),
""")

    # Compose the full Dart file
    dart_code = textwrap.dedent(f"""\
// ═══════════════════════════════════════════════════════════════════════
// NamingEngine — 288 MBTI × Enneagram naming data
// All 16 MBTI × 18 Enneagram = 288 combinations (16 preserved + 272 generated)
// ═══════════════════════════════════════════════════════════════════════

class PersonalityName {{
  final String mbti;
  final String enneagram;
  final String healthLevel;
  final String nameCanto;
  final String tagline;
  final String encourage;
  final String emoji;

  PersonalityName({{
    required this.mbti,
    required this.enneagram,
    required this.healthLevel,
    required this.nameCanto,
    required this.tagline,
    this.encourage = '',
    this.emoji = '🧠',
  }});
}}

class NamingEngine {{
  static const List<String> mbtiTypes = [
    'ENFJ', 'ENFP', 'ENTJ', 'ENTP',
    'ESFJ', 'ESFP', 'ESTJ', 'ESTP',
    'INFJ', 'INFP', 'INTJ', 'INTP',
    'ISFJ', 'ISFP', 'ISTJ', 'ISTP',
  ];

  static const List<String> enneagramTypes = [
    '1w9', '1w2',
    '2w1', '2w3',
    '3w2', '3w4',
    '4w3', '4w5',
    '5w4', '5w6',
    '6w5', '6w7',
    '7w6', '7w8',
    '8w7', '8w9',
    '9w8', '9w1',
  ];

  static final Map<String, PersonalityName> _names = {{
    // ═══ Phase 1: 16 original entries (preserved) ═══
{existing_entries}
    // ═══ Phase 2: 272 generated entries (all remaining combos) ═══
{all_new}
  }};

  static PersonalityName? getName(String mbti, String enneagram) {{
    return _names['${{mbti}}_$enneagram'];
  }}

  static bool hasName(String mbti, String enneagram) {{
    return _names.containsKey('${{mbti}}_$enneagram');
  }}

  static int get totalEntries => _names.length;

  static void addName(PersonalityName name) {{
    _names['${{name.mbti}}_${{name.enneagram}}'] = name;
  }}
}}
""")

    with open('/Users/ca/Documents/@typingself-app/lib/features/personality_naming/naming_engine.dart', 'w', encoding='utf-8') as f:
        f.write(dart_code)

    print("✅ Written to naming_engine.dart")

if __name__ == '__main__':
    main()
