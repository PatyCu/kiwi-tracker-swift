# Domain rules run on each client

Health status, current diet, the timeline and calendar grouping depend on the
device's "now" and time zone, so each client implements them instead of the
backend. The cost is the same rule in Swift and TypeScript, which can drift, so
every client tests the same spec behaviors for each rule.
