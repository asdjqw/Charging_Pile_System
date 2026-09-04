#pragma once

#include "Models.h"

#include <QJsonObject>

namespace JsonCodec {

QJsonObject toJson(const User &value);
QJsonObject toJson(const Admin &value);
QJsonObject toJson(const Station &value);
QJsonObject toJson(const Pile &value);
QJsonObject toJson(const ChargingOrder &value);
QJsonObject toJson(const ChargingReservation &value);
QJsonObject toJson(const InviteCode &value);

User userFromJson(const QJsonObject &object);
Admin adminFromJson(const QJsonObject &object);
Station stationFromJson(const QJsonObject &object);
Pile pileFromJson(const QJsonObject &object);
ChargingOrder orderFromJson(const QJsonObject &object);
ChargingReservation reservationFromJson(const QJsonObject &object);
InviteCode inviteFromJson(const QJsonObject &object);

} // namespace JsonCodec
