import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4

import QtQml 2.2


import QtGraphicalEffects 1.0;
import QtQuick.Layouts 1.1

Rectangle {
    id:root
    anchors.fill: parent

    /********************
            Params
    ********************/
    property double speedMs: 0
    property double maxSpeedMs: 30
    property double minSpeedMs: maxSpeedMs * -1

    property double ropeMeters: 0
    property double minRopeMeters: 0
    property double maxRopeMeters: 800
    property double leftRopeMeters: maxRopeMeters - ropeMeters

    property double power: 0
    property double maxPower: 20
    property double minPower: maxPower * -1

    property double motorKg: 20
    property double minMotorKg: 0
    property double maxMotorKg: 150

    property double tempFets: 0
    property double tempMotor: 0
    property double tempBat: 0

    property double whIn: 0
    property double whOut: 0

    property string motorMode: 'Test mode'

    /********************
            Colors
    ********************/

    property real baseOpacity: 0.4 // На все цвета шкалы накладывается opacity
    property string gaugeColor: '#C7CFD9'
    property string ropeColor: '#733E32'
    property string motorKgColor: 'orange'
    property string powerPositiveColor: 'green'
    property string powerNegativeColor: 'red'
    property string speedPositiveColor: 'steelblue'
    property string speedNegativeColor: 'red'
    property string innerColor: '#efeded'

    property string gaugeAlarmFontColor: '#8e1616'
    property string gaugeFontColor: '#515151'




    property bool debug: false

    /********************
        Default view
    ********************/
    property int diameter: parent.width > parent.height
       ? parent.height
       : parent.width

    property string borderColor: '#515151'      // Цвет границ
    property string color: '#efeded'            // Цвет основного фона
    property int diagLAnc: 55                   // Угол диагональных линий от 12ти часов
    property string ff: 'Roboto'                // Шрифт

    /********************
            Gauge
    ********************/
    property double gaugeHeight: diameter * 0.09;
    property int animationDuration: 100
    property int motorKgLabelStepSize: 30
    property int powerLabelStepSize: 10


    function prettyNumber(number) {
        // Проверить число


        return number.toFixed(0);

    }

    function showStatsInConsole() {
        console.log(qsTr('MotorMode: %1').arg(motorMode));
        console.log(qsTr('Power: %1w').arg(power));
        console.log(qsTr('SpeedMs: %1ms').arg(speedMs));
        console.log(qsTr('RopeMeters %1m, leftMeters: %2m')
                    .arg(ropeMeters)
                    .arg(leftRopeMeters));
        console.log(qsTr('TempFets %1C, TempMotor: %2C, TempBat: %3C')
                    .arg(tempFets)
                    .arg(tempMotor)
                    .arg(tempBat));
        console.log(qsTr('WhIn %1, WhOut: %2')
                    .arg(whIn)
                    .arg(whOut));
    }

    function ropeToAng(value) {
        // 180 - (125 - 55) = 110. рабочий диапазон при дефолтном diagLAnc: -55 до 55

        // Если шкала начинается с отрицательного значения
        var deltaForNegativeMinRope = root.minRopeMeters < 0 ? Math.abs(root.minRopeMeters) : 0;

        // Если шкала начинается с положительного значения
        var deltaForPositiveMinRope = root.minRopeMeters > 0 ? -1 * root.minRopeMeters : 0;

        // Рабочий диапазон нижнего бара в градусах
        var diapAng = 180 - (dl2.rotation - dl1.rotation);

        // Диапазон веревки
        var diapRope = root.maxRopeMeters - root.minRopeMeters;
        var delta = diapAng / diapRope;

        var res = (value + deltaForNegativeMinRope + deltaForPositiveMinRope) * delta;

        // При 0 все распидарасит, поэтому небольшой костыль в 0,1
        return (value === minRopeMeters ? res + 0.1 : res)  - dl1.rotation;
    }

    function speedToAng(value) {
        // 180 - (125 - 55) = 110. рабочий диапазон при дефолтном diagLAnc: 125 - 235

        // Если шкала начинается с отрицательного значения
        var deltaForNegativeMinSpeed = root.minSpeedMs < 0 ? Math.abs(root.minSpeedMs) : 0;

        // Если шкала начинается с положительного значения
        var deltaForPositiveMinSpeed = root.minSpeedMs > 0 ? -1 * root.minSpeedMs : 0;

        // Рабочий диапазон нижнего бара в градусах
        var diapAng = 180 - (dl2.rotation - dl1.rotation);

        // Диапазон скорости
        var diapSpeed = root.maxSpeedMs - root.minSpeedMs;
        var delta = diapAng / diapSpeed;

        return (dl2.rotation + diapAng) - (value + deltaForNegativeMinSpeed + deltaForPositiveMinSpeed) * delta;
    }

    function kgToAng(value) {
        // -125 -55

        // Если шкала начинается с отрицательного значения
        var deltaForNegativeValue = root.minMotorKg < 0 ? Math.abs(root.minMotorKg) : 0;

        // Если шкала начинается с положительного значения
        var deltaForPositiveValue = root.minMotorKg > 0 ? -1 * root.minMotorKg : 0;

        // Рабочий диапазон нижнего бара в градусах
        var diapAng = 180 - (180 - (dl2.rotation - dl1.rotation));

        // Диапазон скорости
        var diapKg = root.maxMotorKg - root.minMotorKg;
        var delta = diapAng / diapKg;

        // 20 - регулировка
        var res =  (value + deltaForNegativeValue + deltaForPositiveValue);

        return (value === root.minMotorKg ? res + 0.1 : res) * delta + (dl1.rotation - 90);
    }


    function powerToAng(value) {
        // 55 - 125

        // Если шкала начинается с отрицательного значения
        var deltaForNegativeValue = root.minPower < 0 ? Math.abs(root.minPower) : 0;

        // Если шкала начинается с положительного значения
        var deltaForPositiveValue = root.minPower > 0 ? -1 * root.minPower : 0;

        // Рабочий диапазон нижнего бара в градусах
        var diapAng = 180 - (180 - (dl2.rotation - dl1.rotation));

        // Диапазон скорости
        var diapPower = root.maxPower - root.minPower;
        var delta = diapAng / diapPower;

        // 20 - регулировка
        var res =  (dl2.rotation - 90) - (value + deltaForNegativeValue + deltaForPositiveValue) * delta;

        // При 0 все распидарасит, поэтому небольшой костыль в 0,1
        return (value === root.minPower ? res + 0.1 : res)
    }


    /*gradient: Gradient {
        GradientStop { position: 0.0; color: '#5b365f' }
        GradientStop { position: 1.0; color: '#ce566a' }
    } */

    Column {
        anchors.fill: parent

        Item {
            width: diameter
            height: diameter

            Component.onCompleted: {
                power = prettyNumber(power);
                speedMs = prettyNumber(speedMs);
                motorKg = prettyNumber(motorKg);
                tempFets = prettyNumber(tempFets);
                tempMotor = prettyNumber(tempMotor);
                tempBat = prettyNumber(tempBat);
                whIn = prettyNumber(whIn);
                whOut = prettyNumber(whOut);
                ropeMeters = prettyNumber(ropeMeters);
                leftRopeMeters = prettyNumber(leftRopeMeters);
                showStatsInConsole();
            }

            Rectangle {
                id: baseLayer

                anchors.fill: parent
                width: root.diameter
                height: root.diameter
                radius: root.diameter / 2
                color: root.color
                border.color: root.borderColor
                border.width: 3

                Item {
                    id: diagonalLine
                    anchors.fill: parent

                    Rectangle {
                        id: dl1
                        width: 1
                        height: root.diameter
                        antialiasing: true
                        color: root.borderColor
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        layer.smooth: true
                        rotation: root.diagLAnc
                    }

                    Rectangle {
                        id: dl2
                        width: 1
                        height: root.diameter
                        antialiasing: true
                        color: root.borderColor
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        layer.smooth: true
                        rotation: 180 - root.diagLAnc
                    }
                }


                /**
                  Все 4 шкалы
                  */
                Item {
                    id: progressBars
                    anchors.fill: parent

                    property real ropeStartAng: dl2.rotation
                    property real ropeEndAng: ropeToAng(root.ropeMeters)

                    property real speedStartAng: speedToAng(0)
                    property real speedEndAng: speedToAng(root.speedMs);

                    property real motorKgStartAng: dl1.rotation - 90
                    property real motorKgEndAng: kgToAng(root.motorKg);

                    property real powerStartAng: 0
                    property real powerEndAng: powerToAng(root.power);

                    /*Behavior on ropeEndAng {
                           id: animationRopeEndAng
                           enabled: true
                           NumberAnimation {
                               duration: root.animationDuration
                               easing.type: Easing.InOutCubic
                           }
                        }

                    Behavior on speedEndAng {
                       id: animationSpeedEndAng
                       enabled: true
                       NumberAnimation {
                           duration: root.animationDuration
                           easing.type: Easing.InOutCubic
                       }
                    }

                    Behavior on motorKgEndAng {
                       id: animationMotorKgEndAng
                       enabled: true
                       NumberAnimation {
                           duration: root.animationDuration
                           easing.type: Easing.InOutCubic
                       }
                    }

                    Behavior on powerEndAng {
                       id: animationPowerEndAng
                       enabled: true
                       NumberAnimation {
                           duration: root.animationDuration
                           easing.type: Easing.InOutCubic
                       }
                    }*/

                    onRopeEndAngChanged: canvas.requestPaint()
                    onSpeedEndAngChanged: canvas.requestPaint()
                    onMotorKgEndAngChanged: canvas.requestPaint()
                    onPowerEndAngChanged: canvas.requestPaint()

                    Canvas {
                        id: canvas
                        opacity: root.baseOpacity;
                        antialiasing: true;
                        contextType: '2d';
                        anchors.fill: parent
                        onPaint: {
                            if (context) {
                                context.reset();

                                var centreX = baseLayer.width / 2;
                                var centreY = baseLayer.height / 2;

                                /** ФОН */
                                context.globalCompositeOperation = 'source-over';
                                context.fillStyle = root.gaugeColor;
                                context.beginPath();
                                context.ellipse(0 + 3, 0 + 3, baseLayer.width - 6, baseLayer.height - 6);
                                context.fill();
                                context.globalCompositeOperation = 'xor';
                                context.fillStyle = root.gaugeColor;
                                context.beginPath();
                                context.ellipse(
                                    circleInner.x,
                                    circleInner.y + (root.diameter * 0.045),
                                    circleInner.width,
                                    circleInner.height - (root.diameter * 0.09)
                                );
                                context.fill();

                                /********** Верхний спидометр ***********/

                                var topEnd = (Math.PI * (parent.ropeEndAng - 90)) / 180
                                var topStart = (Math.PI * (parent.ropeStartAng + 90)) / 180

                                context.beginPath();
                                context.arc(
                                    centreX,
                                    centreY,
                                    baseLayer.radius,
                                    topStart,
                                    topEnd,
                                    false
                                );

                                context.globalCompositeOperation = 'source-atop';
                                context.lineWidth = 200
                                context.strokeStyle = root.ropeColor
                                context.stroke();

                                /********** Нижний спидометр ***********/

                                var bottomStart = (Math.PI * (parent.speedStartAng - 90)) / 180
                                var bottomEnd = (Math.PI * (parent.speedEndAng - 90)) / 180

                                context.beginPath();
                                context.arc(
                                    centreX,
                                    centreY,
                                    baseLayer.radius,
                                    bottomStart,
                                    bottomEnd,
                                    root.speedMs > 0
                                );

                                context.globalCompositeOperation = 'source-atop';
                                context.lineWidth = 200;
                                context.strokeStyle = root.speedMs > 0 ? root.speedPositiveColor : root.speedNegativeColor;
                                context.stroke();

                                /********** Левый спидометр ***********/

                                var leftEnd = (Math.PI * (parent.motorKgStartAng + 180)) / 180
                                var leftStart = (Math.PI * (parent.motorKgEndAng - 180)) / 180

                                context.beginPath();
                                context.arc(
                                    centreX,
                                    centreY,
                                    baseLayer.radius - root.gaugeHeight * 0.4,
                                    leftStart,
                                    leftEnd,
                                    true
                                );

                                context.lineWidth = root.gaugeHeight * 0.7
                                context.strokeStyle = root.motorKgColor;
                                context.stroke();

                                /********** Правый спидометр ***********/

                                var rightEnd = (Math.PI * (parent.powerEndAng)) / 180
                                var rightStart = (Math.PI * (parent.powerStartAng)) / 180

                                context.beginPath();
                                context.arc(
                                    centreX,
                                    centreY,
                                    baseLayer.radius - root.gaugeHeight * 0.4,
                                    rightStart,
                                    rightEnd,
                                    root.power > 0
                                );

                                context.lineWidth = root.gaugeHeight * 0.7
                                context.strokeStyle = root.power > 0 ? root.powerPositiveColor : root.powerNegativeColor;
                                context.stroke()
                            }
                        }
                        onWidthChanged:  { requestPaint (); }
                        onHeightChanged: { requestPaint (); }
                    }

                    Canvas {
                        //opacity: 0.5
                        antialiasing: true;
                        contextType: '2d';
                        anchors.fill: parent
                        onPaint: {
                            if (context) {
                                context.reset ();

                                context.beginPath();

                                var centreX = baseLayer.width / 2;
                                var centreY = baseLayer.height / 2;

                                var topEnd = (Math.PI * (90 - dl1.rotation)) / 180
                                var topStart = (Math.PI * (90 - dl2.rotation)) / 180

                                context.beginPath();
                                context.moveTo(centreX, centreY);
                                context.arc(
                                    centreX,
                                    centreY,
                                    baseLayer.radius - root.gaugeHeight * 0.7,
                                    topStart,
                                    topEnd,
                                    false
                                );

                                context.lineTo(centreX, centreY);
                                context.fillStyle = root.innerColor
                                context.fill()

                                topEnd = (Math.PI * (90 + dl2.rotation)) / 180
                                topStart = (Math.PI * (90 + dl1.rotation)) / 180

                                context.beginPath();
                                context.moveTo(centreX, centreY);
                                context.arc(
                                    centreX,
                                    centreY,
                                    baseLayer.radius - root.gaugeHeight * 0.7,
                                    topStart,
                                    topEnd,
                                    false
                                );

                                context.lineTo(centreX, centreY);
                                context.fillStyle = root.innerColor
                                context.fill()
                            }
                        }
                    }
                }

                Item {
                    id: circleInner;

                    anchors {
                        fill: parent;
                        margins: gaugeHeight;
                        centerIn: parent
                    }
                }

                Item {
                    id: gauge
                    anchors {
                        fill: parent;
                        margins: gaugeHeight * 0.1;
                    }

                    function getTLHY(value, min, max, k = 0.2) {
                        if (value === max) {
                            return root.gaugeHeight * k;
                        } else if (value === min) {
                            return root.gaugeHeight * -k;
                        }
                        return 0;
                    }

                    function getTLHX(value, min, max, k = 0.13) {
                        if (value === max) {
                            return root.gaugeHeight * -k;
                        } else if (value === min) {
                            return root.gaugeHeight * -k;
                        }
                        return 0;
                    }

                    function getTLVY(value, min, max, k = 0.2) {
                        if (value === max) {
                            return root.gaugeHeight * k;
                        } else if (value === min) {
                            return root.gaugeHeight * k;
                        }
                        return 0;
                    }

                    function getTLVX(value, min, max, k = 0.13) {
                        if (value === max) {
                            return root.gaugeHeight * k;
                        } else if (value === min) {
                            return root.gaugeHeight * -k;
                        }
                        return 0;
                    }

                    // k - процент шкалы, который метим красным
                    function getTLColor(value, max, k = 20) {
                        return value >= (max - (max * k / 100))
                                ? root.gaugeAlarmFontColor
                                : root.gaugeFontColor;
                    }

                    function getFontSize(k = 0.04) {
                        return Math.max(10, root.diameter * k);
                    }


                    /**
                      Шкала для кг
                    */
                    CircularGauge {
                        id: kgGauge

                        anchors {
                            fill: parent;
                            margins: 0;
                        }

                        minimumValue: root.minMotorKg
                        maximumValue: root.maxMotorKg
                        value: root.motorKg



                        style: CircularGaugeStyle {
                            minimumValueAngle: -dl2.rotation
                            maximumValueAngle: -dl1.rotation
                            labelInset: root.gaugeHeight
                            labelStepSize: root.motorKgLabelStepSize


                            /**
                              Точка по центру
                            */
                            foreground: Item {
                                visible: false
                            }

                            /**
                              Цифры на шкале
                            */
                            tickmarkLabel:  Text {
                                // k - коэффициент для отступа

                                function getText() {
                                    return styleData.value + ((styleData.value === root.minMotorKg) ? 'kg' : '');
                                }

                                font.pixelSize: gauge.getFontSize()
                                y: gauge.getTLHY(styleData.value, root.minMotorKg, root.maxMotorKg)
                                x: gauge.getTLHX(styleData.value, root.minMotorKg, root.maxMotorKg)
                                color: gauge.getTLColor(styleData.value, root.maxMotorKg)
                                text: this.getText();
                                rotation: root.kgToAng(styleData.value)
                                antialiasing: true
                                font.family: root.ff
                            }

                            /**
                              Мелкие деления
                            */
                            minorTickmark: Rectangle {
                                visible: false
                            }

                            /**
                              Деления
                            */
                            tickmark: Rectangle {
                                antialiasing: true
                                implicitWidth: outerRadius * ((styleData.value === root.maxMotorKg || styleData.value === root.minMotorKg)
                                    ? 0.005
                                    : 0.01)
                                implicitHeight:  (styleData.value === root.maxMotorKg || styleData.value === root.minMotorKg)
                                    ? root.gaugeHeight
                                    : implicitWidth * (styleData.value % (root.motorKgLabelStepSize / 2) ? 3 : 6)
                                color: gauge.getTLColor(styleData.value, root.maxMotorKg)
                            }

                            /**
                              Стрелка
                            */
                            needle: Rectangle {
                                antialiasing: true
                                width: outerRadius * 0.015
                                height: outerRadius * 0.7
                                color: root.gaugeFontColor
                            }
                        }
                    }

                    /**
                      Шкала для power
                    */
                    CircularGauge {
                        id: powerGauge

                        anchors {
                            fill: parent;
                            margins: 0;
                        }

                        minimumValue: root.minPower
                        maximumValue: root.maxPower
                        value: root.power

                        style: CircularGaugeStyle {
                            minimumValueAngle: dl2.rotation
                            maximumValueAngle: dl1.rotation
                            labelInset: root.gaugeHeight
                            labelStepSize: root.powerLabelStepSize

                            /**
                              Точка по центру
                            */
                            foreground: Item {
                                Rectangle {
                                    width: 10
                                    height: width
                                    radius: width / 2
                                    color: root.gaugeFontColor
                                    antialiasing: true
                                    anchors.centerIn: parent
                                }
                            }

                            /**
                              Цифры на шкале
                            */
                            tickmarkLabel:  Text {
                                font.pixelSize: gauge.getFontSize()
                                y: gauge.getTLHY(styleData.value, root.minPower, root.maxPower)
                                x: gauge.getTLHX(styleData.value, root.minPower, root.maxPower, -0.13)
                                text: styleData.value + ((styleData.value === 0) ? 'kw' : '')
                                rotation: root.powerToAng(styleData.value)
                                color: gauge.getTLColor(Math.abs(styleData.value), root.maxPower)
                                antialiasing: true
                                font.family: root.ff
                            }

                            /**
                              Мелкие деления
                            */
                            minorTickmark: Rectangle {
                                visible: false
                            }

                            /**
                              Деления
                            */
                            tickmark: Rectangle {
                                antialiasing: true
                                implicitWidth: outerRadius * ((styleData.value === root.maxPower || styleData.value === root.minPower)
                                    ? 0.005
                                    : 0.01)
                                implicitHeight:  (styleData.value === root.maxPower || styleData.value === root.minPower)
                                    ? root.gaugeHeight
                                    : implicitWidth * ((styleData.value % (root.powerLabelStepSize)) ? 3 : 6)
                                color: gauge.getTLColor(Math.abs(styleData.value), root.maxPower)
                            }

                            /**
                              Стрелка
                            */
                            needle: Rectangle {
                                antialiasing: true
                                width: outerRadius * 0.015
                                height: outerRadius * 0.7
                                color: root.gaugeFontColor
                            }
                        }
                    }

                    /**
                      Шкала для speedMs
                    */
                    CircularGauge {
                        id: speedMsGauge

                        anchors {
                            fill: parent;
                            margins: 0;
                        }

                        minimumValue: root.minSpeedMs
                        maximumValue: root.maxSpeedMs
                        value: root.speedMs

                        style: CircularGaugeStyle {
                            minimumValueAngle: root.speedToAng(root.minSpeedMs)
                            maximumValueAngle: root.speedToAng(root.maxSpeedMs)
                            labelInset: root.gaugeHeight / 2
                            labelStepSize: root.maxSpeedMs

                            /**
                              Точка по центру
                            */
                            foreground: Item {
                                Rectangle {
                                    visible: false
                                }
                            }

                            /**
                              Цифры на шкале
                            */
                            tickmarkLabel:  Text {
                                visible: styleData.value === root.maxSpeedMs || styleData.value === root.minSpeedMs

                                font.pixelSize: gauge.getFontSize(0.04)

                                y: gauge.getTLVY(styleData.value, root.minSpeedMs, root.maxSpeedMs, 0.3)
                                x: gauge.getTLVX(styleData.value, root.minSpeedMs, root.maxSpeedMs, -0.3)


                                text: styleData.value + ((styleData.value === 0) ? 'kw' : '')

                                rotation: styleData.value !== root.maxSpeedMs ? root.speedToAng(styleData.value) - 180 - 90 : root.speedToAng(styleData.value)  - 90

                                color: root.gaugeFontColor
                                antialiasing: true
                                font.family: root.ff
                            }

                            /**
                              Мелкие деления
                            */
                            minorTickmark: Rectangle {
                                visible: false
                            }

                            /**
                              Деления
                            */
                            tickmark: Rectangle {
                                antialiasing: true
                                implicitWidth: outerRadius * ((styleData.value === root.maxSpeedMs || styleData.value === root.minSpeedMs)
                                    ? 0.005
                                    : 0.01)
                                implicitHeight:  (styleData.value === root.maxSpeedMs || styleData.value === root.minSpeedMs)
                                    ? root.gaugeHeight
                                    : implicitWidth * ((styleData.value % (root.maxSpeedMs)) ? 3 : 6)
                                color: root.gaugeFontColor
                            }

                            /**
                              Стрелка
                            */
                            needle: Rectangle {
                                visible: false
                            }
                        }
                    }

                    /**
                      Шкала для rope
                    */
                    CircularGauge {
                        id: ropeMetersGauge

                        anchors {
                            fill: parent;
                            margins: 0;
                        }

                        minimumValue: root.minRopeMeters
                        maximumValue: root.maxRopeMeters
                        value: root.ropeMeters

                        style: CircularGaugeStyle {
                            minimumValueAngle: root.ropeToAng(root.minRopeMeters)
                            maximumValueAngle: root.ropeToAng(root.maxRopeMeters)
                            labelInset: root.gaugeHeight / 2
                            labelStepSize: root.maxRopeMeters

                            /**
                              Точка по центру
                            */
                            foreground: Item {
                                Rectangle {
                                    visible: false
                                }
                            }

                            /**
                              Цифры на шкале
                            */
                            tickmarkLabel:  Text {
                                visible: styleData.value === root.maxRopeMeters || styleData.value === root.minRopeMeters

                                font.pixelSize: gauge.getFontSize(0.04)

                                y: gauge.getTLVY(styleData.value, root.minRopeMeters, root.maxRopeMeters, -0.3)
                                x: gauge.getTLVX(styleData.value, root.minRopeMeters, root.maxRopeMeters, -0.3)


                                text: styleData.value + ((styleData.value === 0) ? 'm' : '')

                                rotation: styleData.value !== root.maxRopeMeters ? root.ropeToAng(styleData.value) - 180 - 90 : root.ropeToAng(styleData.value)  - 90

                                color: root.gaugeFontColor
                                antialiasing: true
                                font.family: root.ff
                            }

                            /**
                              Мелкие деления
                            */
                            minorTickmark: Rectangle {
                                visible: false
                            }

                            /**
                              Деления
                            */
                            tickmark: Rectangle {
                                visible: false
                            }

                            /**
                              Стрелка
                            */
                            needle: Rectangle {
                                visible: false
                            }
                        }
                    }
                }


                /**
                  Значения ropeMeters и leftRopeMeters
                  */
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: root.gaugeHeight / 2 - root.gaugeHeight * 0.25
                    spacing: 2
                    width: Math.max(textLeftRopeMeters.width, ropeMeters.width)


                    Grid {
                        spacing: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        id: textLeftRopeMeters

                        Text {
                            text: root.prettyNumber(root.maxRopeMeters - root.ropeMeters)
                            font.pixelSize: Math.max(10, root.diameter * 0.04)
                            font.family: root.ff
                        }

                        Text {
                            text: 'm'
                            font.pixelSize: Math.max(10, root.diameter * 0.04)
                            font.family: root.ff
                        }
                    }

                    Rectangle {
                        opacity: 0.5
                        width: parent.width
                        height: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.borderColor
                    }

                    Grid {
                        spacing: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        id: textRopeMeters

                        Text {
                            text: root.prettyNumber(root.ropeMeters)
                            font.pixelSize: Math.max(10, root.diameter * 0.04)
                            font.family: root.ff
                        }

                        Text {
                            text: 'm'
                            font.pixelSize: Math.max(10, root.diameter * 0.04)
                            font.family: root.ff
                        }
                    }
                }

                /**
                  Значение speedMs
                  */
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: root.gaugeHeight / 1.5
                    spacing: 5

                    Text {
                        text: root.prettyNumber(root.speedMs)
                        font.pixelSize: Math.max(10, root.diameter * 0.04)
                        font.family: root.ff
                    }

                    Text {
                        text: 'ms'
                        font.pixelSize: Math.max(10, root.diameter * 0.04)
                        font.family: root.ff
                    }
                }

                /**
                  Режим мотора
                  */
                Text {
                    text: root.motorMode
                    anchors.horizontalCenter: parent.horizontalCenter

                    anchors.top: parent.top
                    anchors.topMargin: root.gaugeHeight * 2.4
                    font.pixelSize: Math.max(10, root.diameter * 0.045)
                    font.family: root.ff
                }

                /**
                  Значение motorKg
                  */
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: root.gaugeHeight * 3.4
                    spacing: 5

                    Text {
                        text: root.prettyNumber(root.motorKg)
                        font.pixelSize: Math.max(10, root.diameter * 0.055)
                        font.family: root.ff
                    }

                    Text {
                        text: 'kg'
                        opacity: 0.8
                        font.pixelSize: Math.max(10, root.diameter * 0.055)
                        font.family: root.ff
                    }
                }

                /**
                  Значение power
                  */
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: root.gaugeHeight * 3.4
                    spacing: 5

                    Text {
                        text: root.prettyNumber(root.power)
                        font.pixelSize: Math.max(10, root.diameter * 0.055)
                        font.family: root.ff
                    }

                    Text {
                        text: 'kw'
                        opacity: 0.8
                        font.pixelSize: Math.max(10, root.diameter * 0.055)
                        font.family: root.ff
                    }
                }

                /**
                  Надпись 'Power'
                  */
                Text {
                    text: 'Power'
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: root.gaugeHeight * 2.4
                    font.pixelSize: Math.max(10, root.diameter * 0.035)
                    font.family: root.ff
                }
            }
        }



        Rectangle {
            width: parent.width
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter


            Grid {
                visible: root.debug
                columns: 2
                anchors.fill: parent



                Column {
                    spacing: 10

                    Column {
                        spacing: 5

                        Text {
                            text: 'Rope'
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Slider {
                            id: sliderRope
                            minimumValue: root.minRopeMeters
                            maximumValue: root.maxRopeMeters
                            value: root.ropeMeters

                            onValueChanged: {
                                var res = ropeToAng(value)
                                root.ropeMeters = value;
                            }
                        }
                    }

                    Column {
                        spacing: 5

                        Text {
                            text: 'Speed'
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Slider {
                            id: sliderSpeed
                            minimumValue: root.minSpeedMs
                            maximumValue: root.maxSpeedMs
                            value: root.speedMs;

                            onValueChanged: {
                                var res = speedToAng(value);
                                root.speedMs = value;
                            }
                        }
                    }
                }

                Column {
                    spacing: 10
                    Column {
                        spacing: 5

                        Text {
                            text: 'Kg'
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Slider {
                            id: sliderKg
                            minimumValue: root.minMotorKg
                            maximumValue: root.maxMotorKg
                            value: root.motorKg;

                            onValueChanged: {
                                var res = kgToAng(value);
                                root.motorKg = value;
                            }
                        }
                    }

                    Column {
                        spacing: 5

                        Text {
                            text: 'Power'
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Slider {
                            id: sliderPower
                            minimumValue: root.minPower
                            maximumValue: root.maxPower
                            value: root.power;

                            onValueChanged: {
                                var res = powerToAng(value);
                                root.power = value;
                            }
                        }
                    }
                }
            }
        }
    }
}