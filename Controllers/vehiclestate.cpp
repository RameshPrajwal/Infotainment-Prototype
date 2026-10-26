#include "vehiclestate.h"

VehicleState::VehicleState(QObject *parent)
    : QObject{parent}
    , m_frunkOpen(false)
    , m_trunkOpen(false)
    , m_charging(false)
{
}

bool VehicleState::frunkOpen() const
{
    return m_frunkOpen;
}

bool VehicleState::trunkOpen() const
{
    return m_trunkOpen;
}

bool VehicleState::charging() const
{
    return m_charging;
}

void VehicleState::toggleFrunk()
{
    setFrunkOpen(!m_frunkOpen);
}

void VehicleState::toggleTrunk()
{
    setTrunkOpen(!m_trunkOpen);
}

void VehicleState::toggleCharging()
{
    setCharging(!m_charging);
}

void VehicleState::setFrunkOpen(bool frunkOpen)
{
    if (m_frunkOpen == frunkOpen)
        return;
    m_frunkOpen = frunkOpen;
    emit frunkOpenChanged();
}

void VehicleState::setTrunkOpen(bool trunkOpen)
{
    if (m_trunkOpen == trunkOpen)
        return;
    m_trunkOpen = trunkOpen;
    emit trunkOpenChanged();
}

void VehicleState::setCharging(bool charging)
{
    if (m_charging == charging)
        return;
    m_charging = charging;
    emit chargingChanged();
}
