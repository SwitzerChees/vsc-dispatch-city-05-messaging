# Block 5 - RabbitMQ Event Pipeline

Dieser Baustein zerlegt die In-Memory-Simulation in Producer und Consumer. RabbitMQ transportiert Events ueber den Topic-Exchange `food.events`; das Dashboard bleibt ueber die Control API live.

## Verwendung im Kurs

- Privates Integrationspaket fuer das bestehende Studierenden-Repository
- Kein neues Abgabe-Repository: Die Aenderungen werden in den fortlaufenden Projektstand uebernommen
- Fuer einen reproduzierbaren Stand ist der Release `v1.0.0` zu verwenden
- Die enthaltenen Zugangsdaten sind ausschliesslich fuer das lokale Kurs-Lab bestimmt

## Enthalten

- `customer-simulator`: ein StatefulSet-Pod entspricht einem stabilen Kunden-Producer
- drei Instanzen von `restaurant-worker`: konsumieren nur passende Restaurant-Queues
- `courier-simulator`: ein StatefulSet-Pod entspricht einem permanenten Kurier
- `order-worker`: projiziert Events zunaechst wieder in den API-Zustand
- Eventvertrag, RabbitMQ-Client, Telemetrie und Kubernetes-Ressourcen

## Arbeitsauftrag

1. Routing Keys und Queue Bindings aus dem Eventfluss ableiten.
2. RabbitMQ und die Worker in das System aus Block 4 integrieren.
3. Durable Queues, Acknowledgements, Prefetch und Consumer-Gruppen untersuchen.
4. Einen Restaurant-Consumer stoppen und Queue-Aufbau sowie Nachverarbeitung beobachten.
5. Eine Dead-Letter-Strategie fuer ungueltige Events entwerfen.
6. Customer- und Courier-StatefulSet skalieren und neue stabile Ordinalidentitaeten im Event Stream beobachten.

```bash
go test -race ./...
./scripts/build-images.sh
kubectl --context k3d-delivery-lab apply -k deploy/overlays/block-05-messaging
kubectl --context k3d-delivery-lab -n food-delivery port-forward service/rabbitmq 15672:15672
```

RabbitMQ Management: `http://localhost:15672`, Login `delivery` / `delivery`.

```bash
kubectl --context k3d-delivery-lab -n food-delivery scale statefulset/courier-simulator --replicas=4
kubectl --context k3d-delivery-lab -n food-delivery scale statefulset/customer-simulator --replicas=3
kubectl --context k3d-delivery-lab -n food-delivery scale deployment/restaurant-pizza --replicas=2
```

Abnahme: Eine Bestellung durchlaeuft sichtbar `created`, `accepted`, `courier.assigned`, die Strassenfahrt zum Restaurant, `order.picked_up`, die Fahrt zum Kunden und `delivered`.
