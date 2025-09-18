import '../models/hijri_calendar.dart';

class IslamicEventsData {
  static List<MonthInfo> getHijriMonths() {
    return [
      const MonthInfo(
        monthNumber: 1,
        arabicName: 'مُحَرَّم',
        englishName: 'Muharram',
        description: 'The first month of the Islamic calendar, one of the four sacred months.',
        days: 30,
        significance: ['Sacred month', 'Day of Ashura (10th)', 'Islamic New Year (1st)'],
      ),
      const MonthInfo(
        monthNumber: 2,
        arabicName: 'صَفَر',
        englishName: 'Safar',
        description: 'The second month of the Islamic calendar.',
        days: 29,
        significance: ['No specific religious significance'],
      ),
      const MonthInfo(
        monthNumber: 3,
        arabicName: 'رَبِيع الأَوَّل',
        englishName: 'Rabi\' al-awwal',
        description: 'The third month, believed to be the birth month of Prophet Muhammad (PBUH).',
        days: 30,
        significance: ['Birth of Prophet Muhammad (12th)', 'Mawlid celebrations'],
      ),
      const MonthInfo(
        monthNumber: 4,
        arabicName: 'رَبِيع الآخِر',
        englishName: 'Rabi\' al-thani',
        description: 'The fourth month of the Islamic calendar.',
        days: 29,
        significance: ['Spring season'],
      ),
      const MonthInfo(
        monthNumber: 5,
        arabicName: 'جُمَادَى الأُولَى',
        englishName: 'Jumada al-awwal',
        description: 'The fifth month of the Islamic calendar.',
        days: 30,
        significance: ['Dry season'],
      ),
      const MonthInfo(
        monthNumber: 6,
        arabicName: 'جُمَادَى الآخِرَة',
        englishName: 'Jumada al-thani',
        description: 'The sixth month of the Islamic calendar.',
        days: 29,
        significance: ['Last month of spring'],
      ),
      const MonthInfo(
        monthNumber: 7,
        arabicName: 'رَجَب',
        englishName: 'Rajab',
        description: 'The seventh month, one of the four sacred months.',
        days: 30,
        significance: ['Sacred month', 'Night Journey (27th)', 'Preparation for Ramadan'],
      ),
      const MonthInfo(
        monthNumber: 8,
        arabicName: 'شَعْبَان',
        englishName: 'Sha\'ban',
        description: 'The eighth month, the month before Ramadan.',
        days: 29,
        significance: ['Preparation for Ramadan', 'Night of Mid-Sha\'ban (15th)'],
      ),
      const MonthInfo(
        monthNumber: 9,
        arabicName: 'رَمَضَان',
        englishName: 'Ramadan',
        description: 'The ninth month, the month of fasting and spiritual reflection.',
        days: 30,
        significance: ['Month of fasting', 'Night of Power (Laylat al-Qadr)', 'Quran revelation'],
      ),
      const MonthInfo(
        monthNumber: 10,
        arabicName: 'شَوَّال',
        englishName: 'Shawwal',
        description: 'The tenth month, begins with Eid al-Fitr.',
        days: 29,
        significance: ['Eid al-Fitr (1st)', 'Six days of Shawwal fasting'],
      ),
      const MonthInfo(
        monthNumber: 11,
        arabicName: 'ذُو القَعْدَة',
        englishName: 'Dhu al-Qi\'dah',
        description: 'The eleventh month, one of the four sacred months.',
        days: 30,
        significance: ['Sacred month', 'Preparation for Hajj'],
      ),
      const MonthInfo(
        monthNumber: 12,
        arabicName: 'ذُو الحِجَّة',
        englishName: 'Dhu al-Hijjah',
        description: 'The twelfth month, the month of Hajj pilgrimage.',
        days: 29,
        significance: ['Sacred month', 'Hajj pilgrimage', 'Eid al-Adha (10th)', 'Day of Arafah (9th)'],
      ),
    ];
  }

  static List<IslamicEvent> getIslamicEvents() {
    final currentYear = DateTime.now().year;
    
    return [
      // Fixed annual events (approximate dates)
      IslamicEvent(
        id: 'islamic_new_year',
        title: 'Islamic New Year',
        description: 'The beginning of the new Hijri year, marking the migration of Prophet Muhammad (PBUH) from Mecca to Medina.',
        type: EventType.religious,
        startDate: DateTime(currentYear, 8, 9), // Approximate
        isRecurring: true,
        priority: 5,
        tags: ['hijri', 'new_year', 'migration'],
      ),
      IslamicEvent(
        id: 'ashura',
        title: 'Day of Ashura',
        description: 'The 10th day of Muharram, a day of fasting and remembrance.',
        type: EventType.religious,
        startDate: DateTime(currentYear, 8, 18), // Approximate
        isRecurring: true,
        priority: 5,
        tags: ['fasting', 'muharram', 'ashura'],
      ),
      IslamicEvent(
        id: 'mawlid',
        title: 'Mawlid an-Nabi',
        description: 'Celebration of the birth of Prophet Muhammad (PBUH).',
        type: EventType.celebration,
        startDate: DateTime(currentYear, 10, 16), // Approximate
        isRecurring: true,
        priority: 4,
        tags: ['prophet', 'birth', 'celebration'],
      ),
      IslamicEvent(
        id: 'isra_miraj',
        title: 'Isra and Mi\'raj',
        description: 'The Night Journey of Prophet Muhammad (PBUH) from Mecca to Jerusalem and ascension to heaven.',
        type: EventType.religious,
        startDate: DateTime(currentYear, 2, 18), // Approximate
        isRecurring: true,
        priority: 4,
        tags: ['journey', 'miracle', 'jerusalem'],
      ),
      IslamicEvent(
        id: 'ramadan_start',
        title: 'Beginning of Ramadan',
        description: 'The start of the holy month of fasting.',
        type: EventType.religious,
        startDate: DateTime(currentYear, 3, 11), // Approximate
        endDate: DateTime(currentYear, 4, 9), // Approximate
        isRecurring: true,
        priority: 5,
        tags: ['ramadan', 'fasting', 'holy_month'],
      ),
      IslamicEvent(
        id: 'laylat_al_qadr',
        title: 'Laylat al-Qadr',
        description: 'The Night of Power, when the Quran was first revealed.',
        type: EventType.religious,
        startDate: DateTime(currentYear, 4, 5), // Approximate (27th night of Ramadan)
        isRecurring: true,
        priority: 5,
        tags: ['quran', 'revelation', 'power', 'ramadan'],
      ),
      IslamicEvent(
        id: 'eid_fitr',
        title: 'Eid al-Fitr',
        description: 'Festival of breaking the fast, celebrating the end of Ramadan.',
        type: EventType.celebration,
        startDate: DateTime(currentYear, 4, 10), // Approximate
        endDate: DateTime(currentYear, 4, 12), // 3 days
        isRecurring: true,
        priority: 5,
        tags: ['eid', 'celebration', 'ramadan_end'],
      ),
      IslamicEvent(
        id: 'arafah',
        title: 'Day of Arafah',
        description: 'The most important day of Hajj pilgrimage, a day of fasting for non-pilgrims.',
        type: EventType.pilgrimage,
        startDate: DateTime(currentYear, 6, 27), // Approximate
        isRecurring: true,
        priority: 5,
        tags: ['hajj', 'arafah', 'fasting', 'pilgrimage'],
      ),
      IslamicEvent(
        id: 'eid_adha',
        title: 'Eid al-Adha',
        description: 'Festival of Sacrifice, commemorating Ibrahim\'s willingness to sacrifice his son.',
        type: EventType.celebration,
        startDate: DateTime(currentYear, 6, 28), // Approximate
        endDate: DateTime(currentYear, 7, 1), // 4 days
        isRecurring: true,
        priority: 5,
        tags: ['eid', 'sacrifice', 'ibrahim', 'hajj'],
      ),
    ];
  }

  static List<FastingDay> getFastingDays() {
    final currentYear = DateTime.now().year;
    
    return [
      FastingDay(
        id: 'ashura_fast',
        name: 'Day of Ashura',
        description: 'Recommended fasting on the 10th of Muharram',
        type: FastingType.ashura,
        isObligatory: false,
        date: DateTime(currentYear, 8, 18), // Approximate
        reward: 'Expiates the sins of the previous year',
        guidelines: [
          'Fast on the 9th and 10th or 10th and 11th',
          'Recommended to also fast the day before or after',
        ],
      ),
      FastingDay(
        id: 'arafah_fast',
        name: 'Day of Arafah',
        description: 'Recommended fasting on the 9th of Dhu al-Hijjah for non-pilgrims',
        type: FastingType.arafah,
        isObligatory: false,
        date: DateTime(currentYear, 6, 27), // Approximate
        reward: 'Expiates the sins of the previous and coming year',
        guidelines: [
          'Only for those not performing Hajj',
          'One of the most recommended fasts',
        ],
      ),
      // Add Monday and Thursday fasts
      ...List.generate(52, (week) {
        final monday = DateTime(currentYear, 1, 1).add(Duration(days: week * 7));
        final adjustedMonday = monday.add(Duration(days: (DateTime.monday - monday.weekday) % 7));
        
        return FastingDay(
          id: 'monday_${week + 1}',
          name: 'Monday Fast',
          description: 'Sunnah fasting on Monday',
          type: FastingType.mondayThursday,
          isObligatory: false,
          date: adjustedMonday,
          reward: 'Following the Sunnah of the Prophet',
          guidelines: ['Fast from dawn to sunset'],
        );
      }),
      ...List.generate(52, (week) {
        final thursday = DateTime(currentYear, 1, 1).add(Duration(days: week * 7));
        final adjustedThursday = thursday.add(Duration(days: (DateTime.thursday - thursday.weekday) % 7));
        
        return FastingDay(
          id: 'thursday_${week + 1}',
          name: 'Thursday Fast',
          description: 'Sunnah fasting on Thursday',
          type: FastingType.mondayThursday,
          isObligatory: false,
          date: adjustedThursday,
          reward: 'Following the Sunnah of the Prophet',
          guidelines: ['Fast from dawn to sunset'],
        );
      }),
    ];
  }

  static List<IslamicEvent> getEventsForCurrentMonth() {
    final now = DateTime.now();
    return getIslamicEvents().where((event) {
      return event.startDate.month == now.month;
    }).toList();
  }

  static List<FastingDay> getFastingDaysForCurrentMonth() {
    final now = DateTime.now();
    return getFastingDays().where((fasting) {
      return fasting.date.month == now.month;
    }).toList();
  }
}