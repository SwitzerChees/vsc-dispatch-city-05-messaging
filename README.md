# Block 5 - RabbitMQ Event Pipeline

Dieser Baustein zerlegt die In-Memory-Simulation in Producer und Consumer. RabbitMQ transportiert Events ueber den Topic-Exchange `food.events`; das Dashboard bleibt ueber die Control API live.

## Verwendung im Kurs

- Privates Integrationspaket fuer den bestehenden Projektstand aus Block 4
- Installation mit `install.sh` oder `install.ps1`; kein manuelles Kopieren
- Reproduzierbare Lab-Events mit `scripts/lab-publish.sh` oder `scripts/lab-publish.ps1`
- Die Zugangsdaten sind ausschliesslich fuer das lokale Kurs-Lab bestimmt

```bash
../vsc-dispatch-city-05-messaging/install.sh .
```

```powershell
& "..\vsc-dispatch-city-05-messaging\install.ps1" -Target "."
```

## Enthalten

- `customer-simulator`: ein StatefulSet-Pod entspricht einem stabilen Kunden-Producer
- drei Instanzen von `restaurant-worker`: konsumieren nur passende Restaurant-Queues
- `courier-simulator`: ein StatefulSet-Pod entspricht einem permanenten Kurier
- `order-worker`: projiziert Events zunaechst wieder in den API-Zustand
- Eventvertrag, RabbitMQ-Client, Telemetrie und Kubernetes-Ressourcen
- RabbitMQ 4.3.5 mit lokalem 1-GiB-PersistentVolumeClaim

## Arbeitsauftrag

1. Routing Keys und Queue Bindings aus dem Eventfluss ableiten.
2. RabbitMQ und die Worker in das System aus Block 4 integrieren.
3. Durable Queues, Acknowledgements, Prefetch und Consumer-Gruppen untersuchen.
4. Einen Restaurant-Consumer stoppen und Queue-Aufbau sowie Nachverarbeitung beobachten.
5. Eine ungueltige Nachricht gezielt in der Dead Letter Queue beobachten.
6. Competing Consumers skalieren und das Abarbeiten eines Rueckstaus vergleichen.

```bash
go test -race ./...
./scripts/build-images.sh
CLUSTER=teko-k8s ./scripts/load-images.sh
kubectl --context k3d-teko-k8s apply -k deploy/overlays/block-05-messaging
kubectl --context k3d-teko-k8s -n food-delivery port-forward service/rabbitmq 15672:15672
```

RabbitMQ Management: `http://localhost:15672`, Login `delivery` / `delivery`.

Der Broker laeuft im Laptop-Lab bewusst als einzelne Instanz. Durable Queues, persistente Nachrichten und das PVC schuetzen den lokalen Zustand, ergeben aber noch keine Hochverfuegbarkeit.

```bash
kubectl --context k3d-teko-k8s -n food-delivery scale statefulset/courier-simulator --replicas=4
kubectl --context k3d-teko-k8s -n food-delivery scale statefulset/customer-simulator --replicas=3
kubectl --context k3d-teko-k8s -n food-delivery scale deployment/restaurant-pizza --replicas=2
```

Abnahme: Eine Bestellung durchlaeuft sichtbar `created`, `accepted`, `courier.assigned`, die Strassenfahrt zum Restaurant, `order.picked_up`, die Fahrt zum Kunden und `delivered`.
