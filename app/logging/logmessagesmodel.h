#ifndef LOGMESSAGESMODEL_H
#define LOGMESSAGESMODEL_H

#include <QAbstractListModel>
#include <QColor>

//TODO remove me
#include "../telemetry/qopenhdmavlinkhelper.hpp"

/**
 * @brief All OpenHD and QOpenHD Log messages are accumulated and processed here.
 * There is only one static instance of this class in the whole application, and this
 * model instance is registered in main() to be accessible by qml for display.
 * Note: This is for showing log messages in the config menu, NOT for the log messages that
 * show up in the HUD (HUD messages have their own model)
 */
class LogMessagesModel : public QAbstractListModel
{
    Q_OBJECT
public:
    struct LogMessageData{
        QString tag;
        QString message;
        quint64 timestamp=0;
        QColor severity_color{0,255,0,255};
    };
public:
    static  LogMessagesModel& instance();
    enum Roles {
        TagRole = Qt::UserRole,
        MessageRole,
        TimestampRole,
        SeverityColorRole
    };

    explicit  LogMessagesModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex& parent= QModelIndex()) const override;
    QVariant data( const QModelIndex& index, int role = Qt::DisplayRole ) const override;
    QHash<int, QByteArray> roleNames() const override;
    static QColor log_severity_to_color(quint8 severity){
        return QColor{0,255,0,255};
    }
    void addLogMessage(const QString tag,QString message,quint8 severity);
    // now this is really stupid, but aparently one cannot change the model from a non qt ui thread.
    // Therefore, every time "addLogMessage" is called we emit a signal (signalAddLogMessage) that is connected to
    // do_not_call_me_addLogMessage. This way, addData is called from the UI thread (or at least I think thats whats happening,
    // all I know is that without this workaround this fuck doesn't work (the UI doesn't change).
    void do_not_call_me_addLogMessage(QString tag,QString message,quint8 severity){
        addData({tag,message,0,log_severity_to_color(severity)});
    }
public slots:
    void removeData(int row);
    void addData(LogMessagesModel::LogMessageData logMessageData);
private:
    QVector< LogMessageData > m_data;
public:
signals:
    void signalAddLogMessage(QString tag,QString message,quint8 severity);
};

#endif // LOGMESSAGESMODEL_H