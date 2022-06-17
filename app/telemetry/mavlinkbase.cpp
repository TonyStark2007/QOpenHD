#include "mavlinkbase.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#ifndef __windows__
#include <unistd.h>
#endif

#include <QtNetwork>
#include <QThread>
#include <QtConcurrent>
#include <QFutureWatcher>
#include <QFuture>

#include <openhd/mavlink.h>
#include "../rc/openhdrc.h"
#include "qopenhdmavlinkhelper.hpp"
#include "../util/util.h"

/*
 * Note: this class now has several crude hacks for handling the different sysid/compid combinations
 * used by different flight controller firmware, this is the wrong way to do it but won't cause any
 * problems yet.
 *
 */
MavlinkBase::MavlinkBase(QObject *parent): QObject(parent), m_ground_available(false) {
    qDebug() << "MavlinkBase::MavlinkBase()";
    mOHDConnection=std::make_unique<OHDConnection>(nullptr,false);
    mOHDConnection->registerNewMessageCalback([this](mavlink_message_t msg){
        emit processMavlinkMessage(msg);
    });
}

void MavlinkBase::onStarted() {
    emit setup();
}

void MavlinkBase::set_loading(bool loading) {
    m_loading = loading;
    emit loadingChanged(m_loading);
}


void MavlinkBase::set_saving(bool saving) {
    m_saving = saving;
    emit savingChanged(m_saving);
}

void MavlinkBase::sendData(mavlink_message_t msg) {
    mOHDConnection->sendMessage(msg);
}

QVariantMap MavlinkBase::getAllParameters() {
    qDebug() << "MavlinkBase::getAllParameters()";
    return m_allParameters;
}


void MavlinkBase::fetchParameters() {
    auto mavlink_sysid=getQOpenHDSysId();
    mavlink_message_t msg;
    mavlink_msg_param_request_list_pack(mavlink_sysid, MAV_COMP_ID_MISSIONPLANNER, &msg, targetSysID, targetCompID);
    sendData(msg);

}

void MavlinkBase::joystick_Present_Changed(bool joystickPresent) {
    qDebug() << "MavlinkBase::joystick_Present_Changed:"<< joystickPresent;
    if (joystickPresent == true){
        //qDebug() << "MavlinkBase::joystick_Present_Changed: starting timer for RC msgs";
        //m_rc_timer->start(20);
    }
    else{
        //qDebug() << "MavlinkBase::joystick_Present_Changed: stopping timer for RC msgs";
        //m_rc_timer->stop();
    }
}

void MavlinkBase::receive_RC_Update(std::array<uint,19> rcValues) {
    qDebug() << "MavlinkBase::receive_RC_Update=";
     m_rc_values=rcValues;
}

void MavlinkBase::sendRC () {
    QSettings settings;
    bool enable_rc = settings.value("enable_rc", false).toBool();
    //temporarily dsabled
    if(true){
        return;
    }
    if (enable_rc == true){
        mavlink_message_t msg;
        //TODO mavlink sysid is hard coded at 255... in app its default is 225
        mavlink_msg_rc_channels_override_pack(QOpenHDMavlinkHelper::getSysId(), MAV_COMP_ID_MISSIONPLANNER, &msg, targetSysID, targetCompID,
                                              m_rc_values[0],m_rc_values[1],m_rc_values[2],m_rc_values[3],m_rc_values[4],m_rc_values[5],m_rc_values[6],m_rc_values[7],
                m_rc_values[8],m_rc_values[9],m_rc_values[10],m_rc_values[11],m_rc_values[12],m_rc_values[13],m_rc_values[14],m_rc_values[15],
                m_rc_values[16],m_rc_values[17]);
            sendData(msg);
    }
    else {
        return;
    }

}

void MavlinkBase::requestAutopilotInfo() {
    qDebug() << "MavlinkBase::request_Autopilot_Info";
    auto mavlink_sysid=getQOpenHDSysId();
    mavlink_message_t msg;
    mavlink_msg_autopilot_version_request_pack(mavlink_sysid, MAV_COMP_ID_MISSIONPLANNER, &msg, targetSysID,targetCompID);
    sendData(msg);
}

int MavlinkBase::getQOpenHDSysId()
{
    return QOpenHDMavlinkHelper::getSysId();
}


void MavlinkBase::request_Mission_Changed() {
    qDebug() << "MavlinkBase::request_Mission_Changed";
    auto mavlink_sysid=getQOpenHDSysId();
    mavlink_message_t msg;
    mavlink_msg_mission_request_list_pack(mavlink_sysid, MAV_COMP_ID_MISSIONPLANNER, &msg, targetSysID,targetCompID,0);
    sendData(msg);
}

void MavlinkBase::get_Mission_Items(int total) {
    qDebug() << "MavlinkBase::get_Mission_Items total="<< total;
    auto mavlink_sysid=getQOpenHDSysId();
    mavlink_message_t msg;
    int current_seq;
    for (current_seq = 1; current_seq < total; ++current_seq){
        //qDebug() << "MavlinkBase::get_Mission_Items current="<< current_seq;
        mavlink_msg_mission_request_int_pack(mavlink_sysid, MAV_COMP_ID_MISSIONPLANNER, &msg, targetSysID,targetCompID,current_seq,0);
        sendData(msg);
    }
}

void MavlinkBase::send_Mission_Ack() {
    qDebug() << "MavlinkBase::send_Mission_Ack";
    auto mavlink_sysid=getQOpenHDSysId();
    mavlink_message_t msg;
    mavlink_msg_mission_ack_pack(mavlink_sysid, MAV_COMP_ID_MISSIONPLANNER, &msg, targetSysID,targetCompID,0,0);
    sendData(msg);
}

bool MavlinkBase::isConnectionLost() {
    /* we want to know if a heartbeat has been received (not -1, the default)
       but not in the last 5 seconds.*/
    if (m_last_heartbeat > -1 && m_last_heartbeat < 5000) {
        return false;
    }
    return true;
}

void MavlinkBase::resetParamVars() {
    m_allParameters.clear();
    parameterCount = 0;
    parameterIndex = 0;
    initialConnectTimer = -1;
    /* give the MavlinkStateGetParameters state a chance to receive a parameter
       before timing out */
    parameterLastReceivedTime = QDateTime::currentMSecsSinceEpoch();
}


void MavlinkBase::stateLoop() {
    qint64 current_timestamp = QDateTime::currentMSecsSinceEpoch();
    set_last_heartbeat(current_timestamp - last_heartbeat_timestamp);

    set_last_attitude(current_timestamp - last_attitude_timestamp);
    set_last_battery(current_timestamp - last_battery_timestamp);
    set_last_gps(current_timestamp - last_gps_timestamp);
    set_last_vfr(current_timestamp - last_vfr_timestamp);

    return;

    switch (state) {
        case MavlinkStateDisconnected: {
            set_loading(false);
            set_saving(false);
            if (m_ground_available) {
                state = MavlinkStateConnected;
            }
            break;
        }
        case MavlinkStateConnected: {
            if (initialConnectTimer == -1) {
                initialConnectTimer = QDateTime::currentMSecsSinceEpoch();
            } else if (current_timestamp - initialConnectTimer < 5000) {
                state = MavlinkStateGetParameters;
                resetParamVars();
                fetchParameters();
            }
            break;
        }
        case MavlinkStateGetParameters: {
            set_loading(true);
            set_saving(false);
            qint64 currentTime = QDateTime::currentMSecsSinceEpoch();

            if (isConnectionLost()) {
                resetParamVars();
                m_ground_available = false;
                state = MavlinkStateDisconnected;
            }

            if ((parameterCount != 0) && parameterIndex == (parameterCount - 1)) {
                emit allParametersChanged();
                state = MavlinkStateIdle;
            }

            if (currentTime - parameterLastReceivedTime > 7000) {
                resetParamVars();
                m_ground_available = false;
                state = MavlinkStateDisconnected;
            }
            break;
        }
        case MavlinkStateIdle: {
            set_loading(false);

            if (isConnectionLost()) {
                resetParamVars();
                m_ground_available = false;
                state = MavlinkStateDisconnected;
            }

            break;
        }
    }
}


/*void MavlinkBase::processMavlinkTCPData() {
    QByteArray data = mavlinkSocket->readAll();
    processData(data);
}


void MavlinkBase::processMavlinkUDPDatagrams() {
    QByteArray datagram;

    while ( ((QUdpSocket*)mavlinkSocket)->hasPendingDatagrams()) {
        m_ground_available = true;

        datagram.resize(int(((QUdpSocket*)mavlinkSocket)->pendingDatagramSize()));
        QHostAddress _groundAddress;
        quint16 groundPort;
         ((QUdpSocket*)mavlinkSocket)->readDatagram(datagram.data(), datagram.size(), &_groundAddress, &groundPort);
        groundUDPPort = groundPort;
        processData(datagram);
    }
}*/


/*void MavlinkBase::processData(QByteArray data) {
    typedef QByteArray::Iterator Iterator;
    mavlink_message_t msg;

    for (Iterator i = data.begin(); i != data.end(); i++) {
        char c = *i;

        uint8_t res = mavlink_parse_char(MAVLINK_COMM_0, (uint8_t)c, &msg, &r_mavlink_status);

        if (res) {
            //Not the target we're talking to, so reject it
            if (m_restrict_sysid && (msg.sysid != targetSysID)) {
                return;
            }

            if (m_restrict_compid && (msg.compid != targetCompID)) {
                return;
            }

            // process ack messages in the base class, subclasses will receive a signal
            // to indicate success or failure
            if (msg.msgid == MAVLINK_MSG_ID_COMMAND_ACK) {
                mavlink_command_ack_t ack;
                mavlink_msg_command_ack_decode(&msg, &ack);
                switch (ack.result) {
                    case MAV_CMD_ACK_OK: {
                        m_command_state = MavlinkCommandStateDone;
                        break;
                    }
                    default: {
                        m_command_state = MavlinkCommandStateFailed;
                        break;
                    }
                }
            } else {
                emit processMavlinkMessage(msg);
            }
        }
    }
}*/


void MavlinkBase::set_last_heartbeat(qint64 last_heartbeat) {
    m_last_heartbeat = last_heartbeat;
    emit last_heartbeat_changed(m_last_heartbeat);
}

void MavlinkBase::set_last_attitude(qint64 last_attitude) {
    m_last_attitude = last_attitude;
    emit last_attitude_changed(m_last_attitude);
}

void MavlinkBase::set_last_battery(qint64 last_battery) {
    m_last_battery = last_battery;
    emit last_battery_changed(m_last_battery);
}

void MavlinkBase::set_last_gps(qint64 last_gps) {
    m_last_gps = last_gps;
    emit last_gps_changed(m_last_gps);
}

void MavlinkBase::set_last_vfr(qint64 last_vfr) {
    m_last_vfr = last_vfr;
    emit last_vfr_changed(m_last_vfr);   
}

void MavlinkBase::setDataStreamRate(MAV_DATA_STREAM streamType, uint8_t hz) {
    auto mavlink_sysid=getQOpenHDSysId();
    mavlink_message_t msg;
    msg.sysid = mavlink_sysid;
    msg.compid = MAV_COMP_ID_MISSIONPLANNER;
    /*
     * This only sends the message to sysid 1 compid 1 because nothing else responds to this
     * message anyway, iNav uses a fixed rate and so does betaflight
     *
     */
    mavlink_msg_request_data_stream_pack(mavlink_sysid, MAV_COMP_ID_MISSIONPLANNER, &msg, 1, MAV_COMP_ID_AUTOPILOT1, streamType, hz, 1);
    sendData(msg);
}



/*
 * This is the entry point for sending mavlink commands to any component, including flight
 * controllers and microservices.
 *
 * We accept a MavlinkCommand subclass with the fields set according to the type of command
 * being sent, and then we switch the state machine running in commandStateLoop() to the
 * sending state.
 *
 * The state machine then takes care of waiting for a command acknowledgement, and if one
 * is not received within the timeout, the command is resent up to 5 times.
 *
 * Subclasses are responsible for connecting a slot to the commandDone and commandFailed
 * signals to further handle the result.
 *
 */
void MavlinkBase::sendCommand(MavlinkCommand command) {
    m_current_command.reset(new MavlinkCommand(command));
    m_command_state = MavlinkCommandStateSend;
}


void MavlinkBase::commandStateLoop() {
    switch (m_command_state) {
        case MavlinkCommandStateReady: {
            // do nothing, no command being sent
            break;
        }
        case MavlinkCommandStateSend: {
        qDebug() << "CMD SEND";
            mavlink_message_t msg;
            m_command_sent_timestamp = QDateTime::currentMSecsSinceEpoch();
            auto mavlink_sysid=getQOpenHDSysId();
            //qDebug() << "SYSID=" << mavlink_sysid;
            //qDebug() << "Target SYSID=" << targetSysID;

            if (m_current_command->m_command_type == MavlinkCommandTypeLong) {
                mavlink_msg_command_long_pack(mavlink_sysid, MAV_COMP_ID_MISSIONPLANNER, &msg, targetSysID, targetCompID, m_current_command->command_id, m_current_command->long_confirmation, m_current_command->long_param1, m_current_command->long_param2, m_current_command->long_param3, m_current_command->long_param4, m_current_command->long_param5, m_current_command->long_param6, m_current_command->long_param7);
            } else {
                mavlink_msg_command_int_pack(mavlink_sysid, MAV_COMP_ID_MISSIONPLANNER, &msg, targetSysID, targetCompID, m_current_command->int_frame, m_current_command->command_id, m_current_command->int_current, m_current_command->int_autocontinue, m_current_command->int_param1, m_current_command->int_param2, m_current_command->int_param3, m_current_command->int_param4, m_current_command->int_param5, m_current_command->int_param6, m_current_command->int_param7);          
            }
            sendData(msg);

            // now wait for ack
            m_command_state = MavlinkCommandStateWaitACK;

            break;
        }
        case MavlinkCommandStateWaitACK: {
        qDebug() << "CMD ACK";
            qint64 current_timestamp = QDateTime::currentMSecsSinceEpoch();
            auto elapsed = current_timestamp - m_command_sent_timestamp;

            if (elapsed > 200) {
                // no ack in 200ms, cancel or resend
                qDebug() << "CMD RETRY";
                if (m_current_command->retry_count >= 5) {
                    m_command_state = MavlinkCommandStateFailed;
                    m_current_command.reset();
                    return;
                }
                m_current_command->retry_count = m_current_command->retry_count + 1;
                if (m_current_command->m_command_type == MavlinkCommandTypeLong) {
                    /* incremement the confirmation parameter according to the Mavlink command
                       documentation */
                    m_current_command->long_confirmation = m_current_command->long_confirmation + 1;
                }
                m_command_state = MavlinkCommandStateSend;
            }
            break;
        }
        case MavlinkCommandStateDone: {
            qDebug() << "CMD DONE";
            m_current_command.reset();
            emit commandDone();
            m_command_state = MavlinkCommandStateReady;
            break;
        }
        case MavlinkCommandStateFailed: {
            qDebug() << "CMD FAIL";
            m_current_command.reset();
            emit commandFailed();
            m_command_state = MavlinkCommandStateReady;
            break;
        }
    }
}