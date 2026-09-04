#include "ServerApiClient.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QTextStream>

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    const QString host = argc > 1 ? QString::fromLocal8Bit(argv[1]) : QStringLiteral("127.0.0.1");
    const quint16 port = argc > 2 ? QString::fromLocal8Bit(argv[2]).toUShort() : 9000;
    QTextStream out(stdout);
    auto &client = ServerApiClient::instance();

    if (!client.initialize(host, port) || !client.ping()) {
        out << "health failed: " << client.lastError() << Qt::endl;
        return 1;
    }
    User autoCreatedUser;
    bool created = false;
    const QString newPhone = QStringLiteral("136%1").arg(
        QDateTime::currentMSecsSinceEpoch() % 100000000, 8, 10, QLatin1Char('0'));
    User reg;
    reg.phone = newPhone;
    reg.password = QStringLiteral("test123");
    reg.nickname = QStringLiteral("用户%1").arg(newPhone.right(4));
    if (!client.registerUser(reg)) {
        out << "registration failed: " << client.lastError() << Qt::endl;
        return 2;
    }
    // 重复注册应失败
    if (client.registerUser(reg)) {
        out << "duplicate registration unexpectedly succeeded" << Qt::endl;
        return 2;
    }
    if (!client.phoneLogin(newPhone, autoCreatedUser, created, reg.password)
        || autoCreatedUser.nickname != reg.nickname) {
        out << "login after registration failed: " << client.lastError() << Qt::endl;
        return 2;
    }

    User user;
    if (!client.phoneLogin(QStringLiteral("13800001111"), user, created, QStringLiteral("123456"))) {
        out << "login failed: " << client.lastError() << Qt::endl;
        return 3;
    }
    ChargingReservation staleReservation;
    if (client.getActiveReservation(staleReservation)
        && !client.cancelReservation(staleReservation.id)) {
        out << "stale reservation cleanup failed: " << client.lastError() << Qt::endl;
        return 4;
    }
    const auto stations = client.listStations(39.9042, 116.4074, QString(), QString(), 30);
    if (stations.isEmpty()) {
        out << "no stations: " << client.lastError() << Qt::endl;
        return 5;
    }

    Pile idlePile;
    for (const Station &station : stations) {
        const auto piles = client.listPiles(station.id, QStringLiteral("idle"));
        if (!piles.isEmpty()) {
            idlePile = piles.first();
            break;
        }
    }
    if (idlePile.id <= 0) {
        out << "no idle pile" << Qt::endl;
        return 6;
    }

    ChargingReservation reservation;
    if (!client.createReservation(idlePile.id, reservation)) {
        out << "reservation failed: " << client.lastError() << Qt::endl;
        return 7;
    }
    const QString firstReservationNo = reservation.reservationNo;
    ChargingReservation active;
    if (!client.getActiveReservation(active) || active.id != reservation.id) {
        out << "reservation verification failed" << Qt::endl;
        return 8;
    }
    if (!client.cancelReservation(active.id)) {
        out << "reservation cancellation failed: " << client.lastError() << Qt::endl;
        return 9;
    }
    if (!client.createReservation(idlePile.id, reservation)) {
        out << "second reservation failed: " << client.lastError() << Qt::endl;
        return 10;
    }
    if (reservation.reservationNo == firstReservationNo) {
        out << "reservation number was reused" << Qt::endl;
        return 15;
    }

    ChargingOrder started;
    if (!client.startCharging(user.id, idlePile.id, started)) {
        out << "start failed: " << client.lastError() << Qt::endl;
        return 11;
    }
    if (!client.updateChargingProgress(user.id, started.id, 0.75)) {
        out << "progress failed: " << client.lastError() << Qt::endl;
        return 12;
    }
    ChargingOrder finished;
    if (!client.stopCharging(started.id, 0.75, finished)) {
        out << "stop failed: " << client.lastError() << Qt::endl;
        return 13;
    }
    const auto orders = client.listOrders(user.id);
    if (orders.isEmpty() || orders.first().status != QLatin1String("finished")) {
        out << "order verification failed" << Qt::endl;
        return 14;
    }
    out << "ok stations=" << client.stationCount() << " piles=" << client.pileCount()
        << " order=" << finished.orderNo << " amount=" << finished.amount << Qt::endl;
    return 0;
}
