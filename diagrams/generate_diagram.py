from diagrams import Diagram, Cluster, Edge
from diagrams.azure.compute import FunctionApps
from diagrams.azure.ml import CognitiveServices
from diagrams.azure.integration import EventGridTopics
from diagrams.azure.storage import BlobStorage
from diagrams.azure.database import CosmosDb
from diagrams.azure.monitor import ApplicationInsights
from diagrams.azure.identity import ManagedIdentities
from diagrams.onprem.client import User

with Diagram(
    "AOAI Coding & Review Agents\nEvent Grid Coordination",
    filename="aoai-eventgrid-agents-architecture",
    show=False,
    direction="TB",
    outformat="png",
    graph_attr={
        "fontsize": "16",
        "bgcolor": "white",
        "pad": "0.5",
        "splines": "ortho",
    },
):
    user = User("Developer / API")

    with Cluster("Azure OpenAI"):
        openai = CognitiveServices("Azure OpenAI\n(gpt-4o / gpt-4o-mini)")

    with Cluster("Event Coordination"):
        eventgrid = EventGridTopics("Event Grid\nCustom Topic\n(CloudEvents)")

    with Cluster("Agent Runtime"):
        coder = FunctionApps("Coder Agent\n(Function)")
        reviewer = FunctionApps("Reviewer Agent\n(Function)")

    with Cluster("State & Artifacts"):
        blob = BlobStorage("Blob Storage\ncode-artifacts")
        cosmos = CosmosDb("Cosmos DB\nworkflows/tasks")

    with Cluster("Observability"):
        insights = ApplicationInsights("Application Insights\n+ Log Analytics")

    identity = ManagedIdentities("Managed Identity\n+ RBAC")

    # Flow
    user >> Edge(label="TaskSubmitted") >> eventgrid
    eventgrid >> Edge(label="CodeGenerated") >> coder
    coder >> Edge(label="CodeGenerated") >> eventgrid
    eventgrid >> Edge(label="CodeGenerated") >> reviewer
    reviewer >> Edge(label="ReviewCompleted\n/ ChangesRequested") >> eventgrid
    eventgrid >> Edge(label="ChangesRequested") >> coder

    # Data access
    coder >> Edge(style="dashed", color="gray") >> openai
    reviewer >> Edge(style="dashed", color="gray") >> openai
    coder >> Edge(style="dashed", color="gray") >> blob
    reviewer >> Edge(style="dashed", color="gray") >> blob
    coder >> Edge(style="dashed", color="gray") >> cosmos
    reviewer >> Edge(style="dashed", color="gray") >> cosmos

    # Observability & identity
    coder >> Edge(style="dotted", color="blue") >> insights
    reviewer >> Edge(style="dotted", color="blue") >> insights
    identity >> Edge(style="dotted", color="green") >> openai
    identity >> Edge(style="dotted", color="green") >> eventgrid
    identity >> Edge(style="dotted", color="green") >> blob
    identity >> Edge(style="dotted", color="green") >> cosmos
