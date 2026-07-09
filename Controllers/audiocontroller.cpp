#include "audiocontroller.h"

audioController::audioController(QObject *parent)
    : QObject{parent}
    ,m_volumeLevel(60)
{}

int audioController::volumeLevel() const
{
    return m_volumeLevel;
}



void audioController::incrementVolumeLevel(const int &val)
{
    int newVolumeLevel = m_volumeLevel + val;

    if(newVolumeLevel <= 0)
        newVolumeLevel  = 0;

    if(newVolumeLevel >= 100)
        newVolumeLevel = 100;

    setVolumeLevel( newVolumeLevel);
}

void audioController::setVolumeLevel(int newVolumeLevel)
{
    if (m_volumeLevel == newVolumeLevel)
        return;
    m_volumeLevel = newVolumeLevel;
    emit volumeLevelChanged();
}
