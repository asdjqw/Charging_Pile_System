#pragma once

#include <QByteArray>
#include <QCryptographicHash>
#include <QRandomGenerator>
#include <QString>

namespace PasswordCrypto {

inline QByteArray randomSalt(int bytes = 16)
{
    QByteArray salt;
    salt.resize(bytes);
    auto *rng = QRandomGenerator::global();
    for (int i = 0; i < bytes; ++i)
        salt[i] = char(rng->bounded(256));
    return salt;
}

inline QString hashPassword(const QString &plain)
{
    const QByteArray salt = randomSalt();
    QCryptographicHash digest(QCryptographicHash::Sha256);
    digest.addData(salt);
    digest.addData(plain.toUtf8());
    digest.addData(QByteArrayLiteral("ChargePileLab"));
    return QStringLiteral("sha256$%1$%2")
        .arg(QString::fromLatin1(salt.toHex()),
             QString::fromLatin1(digest.result().toHex()));
}

inline bool isHashed(const QString &stored)
{
    return stored.startsWith(QLatin1String("sha256$"));
}

inline bool verifyPassword(const QString &plain, const QString &storedHash,
                           const QString &legacyPlain = QString())
{
    if (isHashed(storedHash)) {
        const QStringList parts = storedHash.split(QLatin1Char('$'));
        if (parts.size() != 3)
            return false;
        const QByteArray salt = QByteArray::fromHex(parts.at(1).toLatin1());
        const QByteArray expected = QByteArray::fromHex(parts.at(2).toLatin1());
        QCryptographicHash digest(QCryptographicHash::Sha256);
        digest.addData(salt);
        digest.addData(plain.toUtf8());
        digest.addData(QByteArrayLiteral("ChargePileLab"));
        const QByteArray got = digest.result();
        if (got.size() != expected.size())
            return false;
        char acc = 0;
        for (int i = 0; i < got.size(); ++i)
            acc |= char(got.at(i) ^ expected.at(i));
        return acc == 0;
    }
    return !legacyPlain.isEmpty() && plain == legacyPlain;
}

} // namespace PasswordCrypto
