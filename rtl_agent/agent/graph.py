"""Minimal LangGraph-style state graph (stdlib only).

Nodes are functions `state -> None` that mutate a shared state object; routers are functions
`state -> next_node_name | END`.  The trace of visited nodes is recorded for the report.
"""

import time

END = "__end__"


class StateGraph:
    def __init__(self, name="graph"):
        self.name = name
        self.nodes = {}
        self.routes = {}

    def add_node(self, name, fn):
        self.nodes[name] = fn
        return self

    def add_edge(self, src, dst):
        self.routes[src] = lambda _s, _d=dst: _d
        return self

    def add_conditional_edges(self, src, router):
        self.routes[src] = router
        return self

    def run(self, state, entry, max_steps=200, on_step=None):
        node = entry
        steps = 0
        trace = []
        while node != END:
            if node not in self.nodes:
                raise KeyError(f"unknown node {node}")
            steps += 1
            if steps > max_steps:
                raise RuntimeError("graph exceeded max_steps")
            t0 = time.time()
            if node == "finalize" and hasattr(state, "trace"):
                state.trace = list(trace) + [(node, 0.0)]
            self.nodes[node](state)
            trace.append((node, round(time.time() - t0, 2)))
            if on_step:
                on_step(node, state)
            router = self.routes.get(node)
            node = router(state) if router else END
        return trace
