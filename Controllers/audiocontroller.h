#ifndef AUDIOCONTROLLER_H
#define AUDIOCONTROLLER_H

#include <QObject>

class audioController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int volumeLevel READ volumeLevel WRITE setVolumeLevel NOTIFY volumeLevelChanged FINAL)
public:
    explicit audioController(QObject *parent = nullptr);

    int volumeLevel() const;

    Q_INVOKABLE void incrementVolumeLevel( const int & val );

public slots:
    void setVolumeLevel(int newVolumeLevel);

signals:
    void volumeLevelChanged();

private:
    int m_volumeLevel;
};

#endif // AUDIOCONTROLLER_H
