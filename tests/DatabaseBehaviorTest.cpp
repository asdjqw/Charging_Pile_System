#include "DatabaseManager.h"

#include <QCoreApplication>
#include <QTemporaryDir>
#include <QTextStream>

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QTextStream out(stdout);
    QTemporaryDir directory;
    auto &db = DatabaseManager::instance();
    if (!directory.isValid() || !db.initialize(directory.filePath(QStringLiteral("behavior.db")))) {
        out << "database initialization failed: " << db.lastError() << Qt::endl;
        return 1;
    }

    User user;
    user.phone = QStringLiteral("13655558888");
    user.password = QStringLiteral("test123");
    user.nickname = QStringLiteral("测试用户");
    if (!db.registerUser(user)) {
        out << "phone registration failed: " << db.lastError() << Qt::endl;
        return 2;
    }
    // 已注册手机号应拒绝重复注册
    if (db.registerUser(user)) {
        out << "duplicate registration unexpectedly succeeded" << Qt::endl;
        return 2;
    }
    if (!db.loginByPhone(user.phone, user.password, user)) {
        out << "login after register failed: " << db.lastError() << Qt::endl;
        return 2;
    }
    if (!db.setUserStatus(user.id, QStringLiteral("frozen"), 1)) {
        out << "freeze failed: " << db.lastError() << Qt::endl;
        return 3;
    }
    User blocked;
    if (db.loginByPhone(user.phone, QStringLiteral("test123"), blocked)) {
        out << "frozen user unexpectedly logged in" << Qt::endl;
        return 4;
    }
    if (!db.setUserStatus(user.id, QStringLiteral("normal"), 1)
        || !db.loginByPhone(user.phone, QStringLiteral("test123"), blocked)) {
        out << "unfreeze failed: " << db.lastError() << Qt::endl;
        return 5;
    }

    const auto stations = db.listStations();
    if (stations.isEmpty()) {
        out << "no stations" << Qt::endl;
        return 6;
    }
    const auto piles = db.listPiles(stations.first().id, QStringLiteral("idle"));
    if (piles.isEmpty()) {
        out << "no idle piles" << Qt::endl;
        return 7;
    }
    const int pileId = piles.first().id;
    Pile pile;
    if (!db.updatePileStatus(pileId, QStringLiteral("fault"), QStringLiteral("test"),
                             QStringLiteral("测试置为故障后再模拟维修"))) {
        out << "set fault failed: " << db.lastError() << Qt::endl;
        return 8;
    }
    if (!db.restartPile(pileId, 1) || !db.getPile(pileId, pile)
        || pile.status != QLatin1String("restarting")) {
        out << "restart command failed: " << db.lastError() << Qt::endl;
        return 8;
    }
    if (!db.updatePileStatus(pileId, QStringLiteral("idle"), QStringLiteral("pile"),
                             QStringLiteral("测试重启完成"))) {
        out << "restart completion failed: " << db.lastError() << Qt::endl;
        return 9;
    }

    bool fav = false;
    if (!db.toggleFavorite(user.id, QStringLiteral("station"), stations.first().id, fav) || !fav) {
        out << "favorite failed: " << db.lastError() << Qt::endl;
        return 10;
    }
    Admin admin;
    if (!db.registerAdmin(QStringLiteral("newops"), QStringLiteral("ops1234"),
                          QStringLiteral("新运维"), QStringLiteral("CHARGE-ADMIN-2026"), admin)
        || admin.role != QLatin1String("operator")) {
        out << "admin register failed: " << db.lastError() << Qt::endl;
        return 11;
    }
    Admin dup;
    if (db.registerAdmin(QStringLiteral("newops"), QStringLiteral("ops1234"),
                         QStringLiteral("重复"), QStringLiteral("CHARGE-AUDIT-2026"), dup)
        || db.lastError() != QStringLiteral("账户已存在")) {
        out << "duplicate admin not rejected: " << db.lastError() << Qt::endl;
        return 12;
    }

    out << "ok user=" << user.id << " pile=" << pileId << Qt::endl;
    return 0;
}
