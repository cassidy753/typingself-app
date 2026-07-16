// ═══════════════════════════════════════════════════════════════════════
// ZodiacDescriptions — 上升星座 + 月亮星座解讀 + Combo descriptions
// All 12 rising sign descriptions, 12 moon sign descriptions
// ═══════════════════════════════════════════════════════════════════════

/// Rising sign descriptions: external image, first impression, summary
class RisingDescription {
  final String appearance;
  final String firstImpression;
  final String summary;
  const RisingDescription({
    required this.appearance,
    required this.firstImpression,
    required this.summary,
  });
}

/// Moon sign descriptions: emotional pattern, security source, summary
class MoonDescription {
  final String emotionalPattern;
  final String securitySource;
  final String summary;
  const MoonDescription({
    required this.emotionalPattern,
    required this.securitySource,
    required this.summary,
  });
}

class ZodiacDescriptions {
  // ─── Rising sign ───
  static const Map<String, RisingDescription> risingSign = {
    '白羊': RisingDescription(
      appearance: '行動派、直接、熱情',
      firstImpression: '有活力、衝動',
      summary: '你俾人感覺好有幹勁，但小心太急進',
    ),
    '金牛': RisingDescription(
      appearance: '穩定、實在、享受',
      firstImpression: '可靠、慢熱',
      summary: '你外表睇落好穩陣，其實內裡好固執',
    ),
    '雙子': RisingDescription(
      appearance: '健談、機靈、多變',
      firstImpression: '好笑、古靈精怪',
      summary: '你成日俾人覺得好醒目，但變得太快',
    ),
    '巨蟹': RisingDescription(
      appearance: '溫柔、保護、敏感',
      firstImpression: '好傾、有親和力',
      summary: '你外表好似好caring，其實內心好脆弱',
    ),
    '獅子': RisingDescription(
      appearance: '自信、大方、閃亮',
      firstImpression: '有氣場、搶眼',
      summary: '你一出現就俾人注意到，記住唔好太搶鏡',
    ),
    '處女': RisingDescription(
      appearance: '細心、整潔、挑剔',
      firstImpression: '有條理、要求高',
      summary: '你俾人感覺好完美主義，放鬆啲啦',
    ),
    '天秤': RisingDescription(
      appearance: '優雅、社交、和諧',
      firstImpression: '好nice、靚仔靚女',
      summary: '你社交手腕一流，但有時太在意人點睇',
    ),
    '天蠍': RisingDescription(
      appearance: '神秘、深沉、強勢',
      firstImpression: '有威嚴、唔講得笑',
      summary: '你眼神好有壓迫感，但其實內心好炙熱',
    ),
    '人馬': RisingDescription(
      appearance: '樂觀、自由、直率',
      firstImpression: '好玩、隨性',
      summary: '你係開心果，但太隨性會俾人覺得唔可靠',
    ),
    '摩羯': RisingDescription(
      appearance: '穩重、專業、嚴肅',
      firstImpression: '好成熟、好可靠',
      summary: '你似足大人，但記住都要有玩嘅時候',
    ),
    '水瓶': RisingDescription(
      appearance: '獨特、前衛、疏離',
      firstImpression: '好cool、好特別',
      summary: '你思想好超前，但有時太離地',
    ),
    '雙魚': RisingDescription(
      appearance: '夢幻、藝術、同理',
      firstImpression: '好溫柔、好夢幻',
      summary: '你充滿藝術氣息，但小心活喺幻想世界',
    ),
  };

  // ─── Moon sign ───
  static const Map<String, MoonDescription> moonSign = {
    '白羊': MoonDescription(
      emotionalPattern: '直接表達、來得快去得快',
      securitySource: '行動、刺激',
      summary: '你發脾氣嚟得快去得快，最怕悶',
    ),
    '金牛': MoonDescription(
      emotionalPattern: '穩定、需要安全感',
      securitySource: '物質、習慣',
      summary: '你需要穩定嘅感情，最怕變動',
    ),
    '雙子': MoonDescription(
      emotionalPattern: '理智、需要交流',
      securitySource: '溝通、新鮮感',
      summary: '你情感上要人陪傾偈，最怕悶場',
    ),
    '巨蟹': MoonDescription(
      emotionalPattern: '敏感、保護自己',
      securitySource: '家庭、回憶',
      summary: '你內心好敏感，最需要安全感',
    ),
    '獅子': MoonDescription(
      emotionalPattern: '需要被重視、熱情',
      securitySource: '認同、欣賞',
      summary: '你希望被重視，最怕俾人忽略',
    ),
    '處女': MoonDescription(
      emotionalPattern: '細心、有要求、服務',
      securitySource: '秩序、健康',
      summary: '你用行動表達關心，最怕混亂',
    ),
    '天秤': MoonDescription(
      emotionalPattern: '需要和諧、怕衝突',
      securitySource: '關係、平衡',
      summary: '你最怕吵架，寧願妥協都要和諧',
    ),
    '天蠍': MoonDescription(
      emotionalPattern: '深沉、激烈、忠誠',
      securitySource: '信任、深度連結',
      summary: '你愛就愛到盡，恨就恨到徹底',
    ),
    '人馬': MoonDescription(
      emotionalPattern: '樂觀、需要自由',
      securitySource: '探索、意義',
      summary: '你情感上需要空間，最怕被綁住',
    ),
    '摩羯': MoonDescription(
      emotionalPattern: '壓抑、負責任、實際',
      securitySource: '成就、地位',
      summary: '你唔係冇感情，只係習慣收埋',
    ),
    '水瓶': MoonDescription(
      emotionalPattern: '抽離、理性、獨特',
      securitySource: '自由、理想',
      summary: '你感情上好獨立，最怕太黏身',
    ),
    '雙魚': MoonDescription(
      emotionalPattern: '無邊界、犧牲、夢幻',
      securitySource: '浪漫、靈性',
      summary: '你情感好豐富，小心太容易投入',
    ),
  };
}
