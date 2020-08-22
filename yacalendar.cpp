#include "yacalendar.h"
#include <QQmlEngine>

yacalendar::yacalendar()
{

}

QCalendar yacalendar::get_calendar() const
{
    return m_calendar;
}

yacalendar::CalendarTypes yacalendar::get_type() const
{
    return m_type;
}

void yacalendar::set_type(const CalendarTypes &type)
{
    m_type = type;
    init_calendar(m_type);
    emit type_changed(m_type);
}

void yacalendar::register_calendar()
{
    qmlRegisterType<yacalendar>("yacalendar", 1, 0, "CalendarSystem");
}

void yacalendar::init_calendar(yacalendar::CalendarTypes type)
{
    QCalendar::System system = QCalendar::System::Gregorian;
    switch (type)
    {
    case yacalendar::CalendarTypes::Gregorian:
        system = QCalendar::System::Gregorian;
        break;
    case yacalendar::CalendarTypes::Julian:
        system = QCalendar::System::Julian;
        break;
    case yacalendar::CalendarTypes::Jalali:
        system = QCalendar::System::Jalali;
        break;
    case yacalendar::CalendarTypes::IslamicCivil:
        system = QCalendar::System::IslamicCivil;
        break;
    case yacalendar::CalendarTypes::Milankovic:
        system = QCalendar::System::Milankovic;
        break;
    }
    m_calendar = QCalendar(system);
}

QString yacalendar::zero_pad(int number) const
{
    return QString("%1").arg(number, 2, 10, QChar('0'));
}

QString yacalendar::month_name(int month)
{
    return m_calendar.monthName(m_locale, month);
}

int yacalendar::days_in_month(int month) const
{
    return m_calendar.daysInMonth(month);
}

int yacalendar::days_in_month(int month, int year) const
{
    return m_calendar.daysInMonth(month, year);
}

QVariantMap yacalendar::today()
{
    QCalendar::YearMonthDay raw_date = m_calendar.partsFromDate(QDate::currentDate());
    QVariantMap today;
    today["year"] = raw_date.year;
    today["month"] = raw_date.month;
    today["day"] = raw_date.day;
    return today;
}

QString yacalendar::format_date(const QDate &date, const QString &format)
{
    return date.toString(format);
}

QString yacalendar::date_time_tostring(const QDateTime &datetime, const QString &format)
{
    return m_calendar.dateTimeToString(format, datetime, datetime.date(), datetime.time(), m_locale);
}

QVariantMap yacalendar::to_gregorian(int year, int month, int day) const
{
    QDate date = m_calendar.dateFromParts(year, month, day);
    QVariantMap date_map;
    date_map["year"] = date.year();
    date_map["month"] = date.month();
    date_map["day"] = date.day();
    return date_map;
}

QVariantMap yacalendar::to_system_date(int year, int month, int day) const
{
    QCalendar::YearMonthDay date = m_calendar.partsFromDate(QDate(year, month, day));
    QVariantMap date_map;
    date_map["year"] = date.year;
    date_map["month"] = date.month;
    date_map["day"] = date.day;
    return date_map;
}

QString yacalendar::to_system_date(const QDate &date, QChar separator, bool zero_padding) const
{
    QCalendar::YearMonthDay system_date = m_calendar.partsFromDate(date);
    QString year = (zero_padding) ? zero_pad(system_date.year) : QString::number(system_date.year);
    QString month = (zero_padding) ? zero_pad(system_date.month) : QString::number(system_date.month);
    QString day = (zero_padding) ? zero_pad(system_date.day) : QString::number(system_date.day);
    QStringList result = {
        year,
        month,
        day
    };
    return result.join(separator);
}

QString yacalendar::to_system_date(const QString &date, QString in_format, QChar separator, bool zero_padding) const
{
    QDate gregorian_date = QDate::fromString(date, in_format);
    return to_system_date(gregorian_date, separator, zero_padding);
}

QString yacalendar::to_gregorian(const QString& date, QChar in_separator, QString out_format) const
{
    QStringList year_month_day = date.split(in_separator);

    if (year_month_day.count() < 3)
        return QString();

    QDate result = m_calendar.dateFromParts(
                year_month_day.at(0).toUInt(),
                year_month_day.at(1).toInt(),
                year_month_day.at(2).toInt()
                );
    return result.toString(out_format);
}

QDate yacalendar::first_day_of_month(int month, int year) const
{
    QDate first_day_date = m_calendar.dateFromParts(year, month, 1);
    return first_day_date;
}

