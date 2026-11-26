//
//  HeadingService.swift
//  磁力计 / 陀螺仪取磁航向（CoreLocation Heading）
//

import Foundation
import CoreLocation
import Combine

final class HeadingService: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var magneticHeading: Double = 0      // 磁北，顺时针
    @Published var trueHeading: Double = 0          // 真北（需定位授权）
    @Published var hasHeading: Bool = false
    @Published var authorized: Bool = false
    @Published var accuracy: Double = 0

    override init() {
        super.init()
        manager.delegate = self
        manager.headingFilter = 1.0                 // 1° 更新一次
        manager.headingOrientation = .portrait
    }

    func start() {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func stop() {
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let m = newHeading.magneticHeading
        let t = newHeading.trueHeading
        DispatchQueue.main.async {
            self.hasHeading = newHeading.headingAccuracy >= 0
            self.accuracy = newHeading.headingAccuracy

            // 低通平滑，处理 0/360 跨界
            let diff = ((m - self.magneticHeading + 540).truncatingRemainder(dividingBy: 360)) - 180
            self.magneticHeading = CompassRing.norm(self.magneticHeading + diff * 0.25)
            self.trueHeading = t >= 0 ? t : m
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let ok = (status == .authorizedWhenInUse || status == .authorizedAlways)
        DispatchQueue.main.async { self.authorized = ok }
        if ok {
            manager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            }
        }
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        true          // 磁干扰时提示用户做 8 字校准
    }
}
