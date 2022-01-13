import Combine
import CoreLocation
import Foundation

public enum CLLocationManagerError: Error {

    case status(CLAuthorizationStatus)

}

extension CLLocationManager {

    public struct LocationPublisher: Publisher {

        public typealias Output = [CLLocation]
        public typealias Failure = CLLocationManagerError

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = LocationSubscription(subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }

    }

    public static func locationPublisher() -> LocationPublisher {
        return .init()
    }

}

private typealias LocationPublisher = CLLocationManager.LocationPublisher
private typealias Output = CLLocationManager.LocationPublisher.Output
private typealias Failure = CLLocationManager.LocationPublisher.Failure

private final class LocationSubscription<S: Subscriber>: NSObject, CLLocationManagerDelegate, Subscription where S.Input == Output, S.Failure == Failure {

    private let locationManager = CLLocationManager()
    private var wasRequested = false
    private var subscriber: S?
    private var demand: Subscribers.Demand = .none

    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()

        locationManager.delegate = self
    }

    func request(_ demand: Subscribers.Demand) {
        guard let subscriber = subscriber else {
            return
        }

        self.demand = demand

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            subscriber.receive(completion: .failure(.status(locationManager.authorizationStatus)))
        @unknown default:
            break
        }
    }

    func cancel() {
        subscriber = nil
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let subscriber = subscriber, demand > 0 else {
            return
        }
        demand = subscriber.receive(locations)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let subscriber = subscriber, demand > 0 else {
            return
        }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            subscriber.receive(completion: .failure(.status(manager.authorizationStatus)))
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

}
