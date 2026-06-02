#include "hvachandler.h"

HVACHandler::HVACHandler(QObject *parent)
    : QObject{parent}
    , m_targetTemperature( 23 )
{
}

int HVACHandler::targetTemperature() const
{
    return m_targetTemperature;
}

void HVACHandler::incrementTargetTemperature(const int &val)
{
    int newTargetTemp = m_targetTemperature + val;
    setTargetTemperature( newTargetTemp );
}

void HVACHandler::setTargetTemperature(int newTargetTemperature)
{
    if (m_targetTemperature == newTargetTemperature)
        return;
    m_targetTemperature = newTargetTemperature;
    emit targetTemperatureChanged();
}
