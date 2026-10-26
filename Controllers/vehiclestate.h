#ifndef VEHICLESTATE_H
#define VEHICLESTATE_H

#include <QObject>

class VehicleState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool frunkOpen READ frunkOpen WRITE setFrunkOpen NOTIFY frunkOpenChanged)
    Q_PROPERTY(bool trunkOpen READ trunkOpen WRITE setTrunkOpen NOTIFY trunkOpenChanged)
    Q_PROPERTY(bool charging READ charging WRITE setCharging NOTIFY chargingChanged)

public:
    explicit VehicleState(QObject *parent = nullptr);

    bool frunkOpen() const;
    bool trunkOpen() const;
    bool charging() const;

    Q_INVOKABLE void toggleFrunk();
    Q_INVOKABLE void toggleTrunk();
    Q_INVOKABLE void toggleCharging();

public slots:
    void setFrunkOpen(bool frunkOpen);
    void setTrunkOpen(bool trunkOpen);
    void setCharging(bool charging);

signals:
    void frunkOpenChanged();
    void trunkOpenChanged();
    void chargingChanged();

private:
    bool m_frunkOpen;
    bool m_trunkOpen;
    bool m_charging;
};

#endif
