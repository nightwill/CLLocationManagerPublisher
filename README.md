# CLLocationManagerPublisher

### Usage

```swift
struct ContentView: View {

    @State private var locationPublisher = CLLocationManager.locationPublisher().first().replaceError(with: [])
    @State private var locationString = ""
    
    var body: some View {
        Text("Location \(locationString)")
            .onReceive(locationPublisher) { locations in
                locationString = locations.map(\.textDescription).joined(separator: "\n")
            }
    }
}

private extension CLLocation {

    var textDescription: String {
        String(format: "%.5f,%.5f %@", coordinate.latitude, coordinate.longitude, timestamp.description)
    }

}
```
