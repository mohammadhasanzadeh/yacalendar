#ifndef CALENDAR_H
#define CALENDAR_H

#include <QObject>
#include <QCalendar>
#include <QString>
#include <QDate>
#include <QVariantMap>

class yacalendar : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE QString month_name(int month, int format = QLocale::LongFormat);
    Q_INVOKABLE QString month_name(int month, int year, int format);
    Q_INVOKABLE int months_in_year(int year) const;
    Q_INVOKABLE int days_in_month(int month) const;
    Q_INVOKABLE int days_in_month(int month, int year) const;
    Q_INVOKABLE QDate first_day_of_month(int month, int year) const;
    Q_INVOKABLE QVariantMap today();

    Q_INVOKABLE QString format_date(const QDate& date, const QString& format);
    Q_INVOKABLE QString format_date(int year, int month, int day, const QString &format);

    Q_INVOKABLE QString date_time_tostring(const QDateTime &datetime, const QString &format);

    Q_INVOKABLE QVariantMap to_gregorian(int year, int month, int day) const;
    Q_INVOKABLE QString to_gregorian(const QString& date, QChar in_separator, QString out_format) const;
    Q_INVOKABLE QVariantMap to_system_date(int year, int month, int day) const;
    Q_INVOKABLE QString to_system_date(const QDate& date, QChar separator, bool zero_padding = true) const;
    Q_INVOKABLE QString to_system_date(const QString& date, QString in_format, QChar separator, bool zero_padding = true) const;

    Q_INVOKABLE QVariantMap diff_dates(const QDate from, const QDate to);
    Q_INVOKABLE QVariantMap add_month(int year, int month, int day, int n_month);
    Q_INVOKABLE QVariantMap add_days(int year, int month, int day, int n_day);
    Q_INVOKABLE bool is_between(const QDate& source_date, const QDate& from_date, const QDate& to_date, bool by_boundaries = true);
    Q_INVOKABLE bool is_date_valid(int year, int month, int day) const;

    Q_PROPERTY(CalendarTypes type READ get_type WRITE set_type NOTIFY type_changed)
    Q_PROPERTY(QLocale locale MEMBER m_locale NOTIFY locale_changed)

    enum class CalendarTypes
    {
        Gregorian = 0,
        Julian = 8,
        Milankovic = 9,
        Jalali = 10,
        IslamicCivil = 11
    };

    Q_ENUMS(CalendarTypes);

    yacalendar();
    QCalendar get_calendar() const;
    CalendarTypes get_type() const;
    void set_type(const CalendarTypes &type);

    static void register_calendar();

signals:
    void type_changed(CalendarTypes type);
    void locale_changed(QLocale locale);

private:
    QCalendar m_calendar;
    CalendarTypes m_type;
    QLocale m_locale;

    void init_calendar(CalendarTypes type);
    QString zero_pad(int number) const;
};

#endif // CALENDAR_H
