# 第一章 什么是云计算？
我们听说云简化了事情，但它使事情变得复杂更服务（起初）。它为我们省钱，但异常高的账单让许多IT领导和高管感到惊讶。云是弹性的，敏捷和灵活的，但是许多人被锁定到了单一的提供商，这些提供商的架构不够理想，并且需要大量的迁移成本来做变更。我们还听说云不如我们的数据中心安全，仅管这已经被一再证明是错误的。

在许多方面，云计算反映了人性。每个人都相信自己的想法是最好的。人们有时会不顾数据而盲目地遵循自己的信念。没有一个云供应商，云服务或者云架构是完美的。他们都有我们希望与众不同的东西。他们有规则需要遵循，他们都在兜售作为通往真理和应许之地的唯一途径的路线。

云并不能解决所有的问题。它是工具箱中一个有目的的工具。如果使用得当，它是一个令人难以置信的一个补充。如果使用不当，它可能是痛苦的，昂贵的，并且会改变职业生涯。让我们理清它是什么，不是什么。我们稍后将介绍正式的定义，但本质上，云计算是一种用于消费和提供信息技术软件，基础设施和相关服务的新商业模式。此外，本章还包括：
+ 云计算历史
+ 云计算定义
+ 云计算的基本特征
+ 云服务模型
+ 云部署模型
+ 类似的技术模型
+ 云清洗

## 云计算历史
For our purposes, the first age of computing was the 1970s when the focus was on big
infrastructure. Green-screen terminals, in vogue back then, eventually evolved into
personal computers. Networks went from a centralized, hierarchical design to a
decentralized design. Decentralization moved the processing closer to the user meaning
applications moved from thin client (processing on the server) to thick client (processing on
the user/client side). Green screens were tightly coupled interfaces to the data-laden
backend. Decentralization enabled developers to track process steps and state information
on the server side while allowing client-side computers to do much more of the processing.
The period was the birth of client-server architectures, which are central to today's modern
technology-driven business.
With much of the processing moving closer to the actual user, the connectivity of the user
became the main limitation. Lack of connectivity led to the second age of computing. The
80s heralded the rise of the internet. Better connectivity between distributed computing
systems quickly led to the development and near ubiquity of easy-to-use, visually attractive
computing devices. Businesses moved quickly in exploiting this new Internet Protocol (IP)-
based connectivity as local area networks expanded to globally inter-connected wide area
networks. Users, however, became frustrated with poor application performance, network
latency, and application timeouts. Developers were again forced to place more compute
load closer to the user. Tightly coupled centralized applications did not have the functions,
flexibility, or the responsiveness of a well-designed well-built decentralized application.
Additionally, the late 80s gave way to a major shakeup in the telecommunications industry.
The then monopolized local exchanges were mandated to separate into independent
competing companies. The competition forced faster innovation, lower costs, and higher
levels of reliability and service.

The following diagram depicts the various cloud computing phases:
![logo](/_media/c11.png)

## 云计算定义
"Cloud computing is a model for enabling ubiquitous, convenient, on-demand network access to a shared pool of configurable computing resources (for example, networks, servers, storage, applications, and services) that can be rapidly provisioned and released with minimal management effort or service provider interaction."
- US National Institute of Standards and Technology

This definition is the most widely quoted and used version globally. Many countries and industries have adopted it, and this is the highly recommended starting point for your organization's working definition for the cloud. This definition is so important that we should take a few minutes to review it in detail.

Cloud computing is a model. It is not a specific technology. You cannot go and buy a cloud computer. The term is used to describe an economic and operational model for the provisioning and consumption of IT infrastructure and associated services. The term can also be extended to cover both business and public-sector mission models. What do these models enable? Why cloud?

They enable ubiquitous, convenient, on-demand network access to a shared pool of configurable computing resources. Universal, convenient, on-demand network access means from anywhere and at any time. The network may include the global public internet, but it may also refer to a global private network. The concepts of ubiquitous, convenient, and on-demand take the viewpoint of the cloud service provider's intended users. Shared pool means that the individual user or organization does not pay for all the resources in the pool. The end user pays only for what they use when they use it. This concept is the heart of the cloud computing economic model. If you need to pay for the resource even when you are not using it, you are not leveraging the cloud computing economic model. Configurable means that the service capability can be changed essentially in real time to meet a specific user's requirements.

That final phrase, "...can be rapidly provisioned and released with minimal management effort or service provider interaction," implies a high degree of automation. Cloud service providers operate a highly automated, services-oriented platform that requires relatively few people. Automation is enabled through brutal establishment and enforcement of rigorous IT standards. Automation also enables self service, so if a prospective service provider cannot offer their capabilities without human interaction, you should be worried.

## 云计算的基本特征
When the United States National Institute of Standards and Technology (NIST) published the cloud computing definition, they also defined the essential characteristics of this new model. These have come to be more important than the definition in that the characteristics have helped to define and protect the marketplace against all the marketing hype that has accompanied the cloud.

The first characteristic of cloud computing is that it is an on-demand, typically self service model. On-demand, meaning that it can be purchased when needed, for as long as needed, and given back when finished. Self service refers to the consumer's ability to buy, deploy and shut down services without any assistance from the service provider. This speeds up the process controls cost and moves control to the consumer. (Refer back to earlier paragraphs where we discussed the de-centralization and continual innovation of pushing compute and control closer to the edge of the consumer's control and consumer-controlled devices. The same applies here.)

From a security perspective, this has introduced governance challenges about the acquisition, provisioning, use, and operation of cloud-based services. Interestingly, these new services may violate existing organizational policies. By its nature, cloud computing may not require procurement, provisioning, or approval from finance due to its low initial cost, self-service nature, and immediate deployment options. Cloud infrastructure and services can be provisioned by almost anyone with a credit card, also known as shadow IT. For enterprise customers, this low-entry cost, quickly deployed on-demand model may become one of the most important characteristics as it instantly wreaks havoc on governance, security, long-term cost, strategy, internal politics, and collaboration.

The second characteristic, broad network access, is required. Ever heard the phrase
the network is the cloud? Anything referred to as-a-service requires a network connection. How would it be accessed, managed, operated, or utilized without some network connection, typically to the internet using standard protocols that promote use by disparate client platforms? Because the cloud is an always-on and always-accessible offering, users have immediate access to all available resources, and assets. Think convenient access to what you want, when you need it, from any location. In theory, all that is required is internet access and relevant credentials. The mobile device and smart device revolution have introduced an interesting dynamic into the cloud conversation within many organizations. These devices are often able to access relevant resources that users require; however, compatibility issues, ineffective security controls and non-standardization of platforms and software systems have made the first adoption climb more difficult for some enterprises.

The third characteristic, resource pooling, is the characteristic that, in essence, lies at the heart of all that is good about cloud computing. Combining many smaller compute resources into farms or pools that can serve many consumers simultaneously enables dynamic resource allocation and re-allocation, cost predictability, IT resource control, and higher rates of infrastructure utilization. Utilization and consumption patterns directly affect cost. Resource pooling enables different physical and virtual resources to be allocated and re-allocated according to consumer demand. As mentioned earlier, the true cloud innovation was economic, allowing us to stop billing and give back the resource when finished. More often than not, traditional, non-cloud traditional deployments see low- utilization rates for their resources, typically between 10 and 20%. Cloud deployments from pools used across multiple clients or customer groups can see as high as 80 to 90% utilization (100% is not ideal in most cases). Resources can automatically scale and adjust to dynamic needs, workload or resource requirements. Cloud service providers or cloud solution providers (CSPs) typically have scores of resources available, from hundreds to thousands of servers, network devices, and applications, enabling them to quickly and economically accommodate, prioritize and implement the varied size, and complexities each client presents.

The fourth essential characteristic of cloud computing centers on elasticity, the ability to dynamically match the need. Product and service capabilities are developed, acquired, priced, and provisioned elastically, enabling rapid response to continuously changing user demand. To the consumer, capabilities often appear unlimited and easily deployed in any quantity at any time. Because cloud services utilize a consumption-based pay-per-use model, you only pay for what you use. As mentioned earlier, cloud innovation and adoption are being driven mainly by economics that affects strategy. For cyclical loads, applications with intermittent use, seasonal or event-type business cloud eliminates the need to pay for 100% of a physical server (CAPEX) when only 5% is used 2% of the time (OPEX). Think of selling thousands of tickets to an Olympic event. Leading up to the ticket release date, little to no computing resources are needed; however, when the tickets go on sale, they may need to accommodate 100,000 users in the space of 30 minutes-40 minutes. This is where rapid elasticity and cloud computing can be beneficial. Enterprises no longer require traditional IT deployments with substantial capital expenditure up front (CAPEX) to support the temporary project load.

The final key characteristic mentioned here is that the cloud is a constantly measured service. Cloud computing natively offers a unique and important component that traditional IT deployments have struggled to provide measurement and control of resource consumption and utilization. As mentioned often, billing was the big innovation. Cloud resource consumption needed to be measured and billed for accurately. Once that was possible, the true power of the cloud, which included the ability to shut it off, was realized. The capability enabled automated reporting, monitoring, and alerting which provided much-needed transparency between the provider and the client. Like a metered electricity service or cell phone data usage, consumers have transparent and immediate access to usage data enabling immediate behavior change if needed. Itemized billing provides transparent trendable data providing insight that may lead to needed change. Proactive organizations can now utilize this well measured, transparent, granular, trendable data to charge departments or business units for their actual consumption. IT, product development, and finance can now move toward operating collaboratively as a revenue-driving team that can quantify, qualify, and justify exact usage and costs per department, by business function, per leader, and so on something that was incredibly difficult to achieve in traditional IT environments.
The following diagram is a graphical representation of the five essential characteristics of cloud computing:

![logo](/_media/c12.png)

As a side note: people have been utilizing the cloud for years without realizing it. It is not a new thing, but it has just started to port over into more popular arenas. Let's look at internet access as an example.

Characteristic 1: Based on the first characteristic mentioned earlier, how many people dig up the street to put in connectivity when they want to access the internet? None. We pay for it as a service that allows us to use it when we choose.
Characteristic 2: Do we need a network to access the internet? Of course.
Characteristic 3: Do we have dedicated switches, routers, SONET ring, and so on in our living space? No, those resources are pooled by the service provider and shared with all the clients in the area or region.
Characteristic 4: Can we utilize more if we need it? Absolutely. We only use what we need with the ability to scale all the way up to the maximum performance for which we are willing to pay. If more is needed, we call and change what performance level we pay for to match up with the changing need.
Characteristic 5: Are we paying as we go? Is our service metered and measured? Definitely yes. If we choose to stop paying for the service, the service is shut off. We get a bill every month and often have a portal that we can log in to that details what we pay for, what we use, performance details, uptime, downtime, and so on.

## 云计算运营模型
There are many paths to the cloud. Each path is grouped based on how the services are offered, deployed, and consumed. The cloud is not a technology. A cloud layer does not exist. Each path to the cloud is a response to a requirement or set of needs based on the consumer's current situation, desired future state, available skills, and resources, as well as tolerance for risk. Cloud products and services often establish reusable and reoccurring architectural patterns (building blocks) used for designing, building, and managing applications and infrastructure.

There are primarily three cloud service models: Internet-as-a-Service (IaaS), Platform-as-a- Service (PaaS), and Software-as-a-Service (SaaS). Deployed as needed, all three models require network connections to change resource pools that are measured in great detail, dynamically. However, each consumption model differs in its approach to a technical solution, economics, complexity risk, and level of acceleration. Deployment models also differ in that they could be public/shared, private/dedicated, community, and hybrid. Each model is unique in how it addresses organizational risk tolerance, economic models, and management preferences.

Often the motivator for a move to the cloud is some event that triggers probing questions. Events could be anything from a magazine article, a blog post to a security breach, infrastructure downtime, a complaint about responsiveness, difficulty managing to the desired level of service, or staff/leadership change. Questions can be typically reduced down to three Es: Expectations, Economics, and Execution. As an example, someone expects more delivered work with smaller budgets and less time, or project execution unexpectedly fails due to budget and staff constraints.

As questions get asked, and solutions considered, strategy details, economics, and technology must align. Solutions that are technically perfect may be too expensive. Low- cost solutions may not match up to chosen strategies going forward. In all cases, economics need to balance or offset chosen risk level. For example, very inexpensive self-managed public cloud servers may not match up to the desired level of isolation and security required for transactional database servers.

Next we discuss ways to think through the three primary models available today. How do we recognize situations in which a cloud model should be a consideration? What are the characteristics of each model? What are the benefits? The following diagram is an overview of the three main service models:

![logo](/_media/c13.png)


## 云服务模型
The different cloud service models are described here in the following sections.

### IaaS - background
Across the industry, hardware has been largely ignored for a very long time. Servers were not sexy. There was no glory for servers. Servers were just a support for the more important applications. Applications got all the credit for solving business challenges. Applications were the things that users interacted with directly. Servers got stuck in dark closets, forgotten and neglected until a problem occurred.

Because servers received no glory, very little to no maintenance and no budget for patching, upgrading, and so on, many servers are now well beyond their service life and prone to failure. Incredible amounts of money will be spent over the next several years rewriting applications, developing new applications, migrating legacy applications, and updating to new cloud-ready functions needed to replace old applications and neglected hardware currently stuck in old closets and worn out in-house data centers.

IaaS gave many the opportunity to upgrade, refresh infrastructure, and move from excessive capital spending to a monthly pay-as-you-go incremental spend. The shift enables strategy changes, go-to-market changes, differences in software development, and changes in handling IT workloads. Think of what hundreds of servers can do in one hour versus one server for hundreds of hours.

### IaaS - things to consider
IaaS is often deployed on-demand in small increments (cores, RAM, storage, network) with billing occurring in small increments of time. Instead of spending the capital (CAPEX) for a large four or eight-core server (which is the smallest currently available from some manufacturers), a right-sized virtual server can be acquired and deployed as a service, matching infrastructure size to cost and immediate need. This flexibility allows for infrastructure to be quickly matched to business strategies and economic constraints.

IaaS can include many of the infrastructure components included in traditional deployments. Firewalls can be virtual or physical. Compute and storage can be deployed across many different styles and platforms. Each service provider has their unique mix of technology and services. Ultimately the goal when using IaaS is to forget about infrastructure management and details and acquire the mix of services needed, when needed, solving the requirements at that time.

IaaS was one of the first cloud models available and has seen significant adoption in nearly all sectors. With IaaS, the user does not manage or control the infrastructure directly, only the software and functions loaded onto it (that is operating system, application). There are different types to choose from with varying levels of management and monitoring available for the underlying hardware, virtualization layers, firewalls, SANs, switches, routers, network interface cards (NIC), and related service level agreements (SLAs). The controlled risk and lower economic entry points for IaaS are attractive to new cloud adopters as well as savvy veterans. Controllable cost and controllable risk provide extra incentive to those trying to modernize through the adoption of the cloud.

The delivery of on-demand capacity is typically handled via self-service online customer portals. The portal provides complete visibility and control of the IaaS environment. Self- service portals enable and automate functions for adds, moves, changes, managing, and reporting without engaging and waiting for other resources internally or within the provider. IaaS can have many different consumption models matching various OPEX and CAPEX requirements. When using IaaS, there is no need to invest capital up front based on compute and storage resources forecasts. IaaS enables infrastructure to be purchased in increments, as needed, to match utilization.

For organizations, IaaS usage metering provides a higher level of detail used to trend utilization and chargeback specific departments or functions based on actual utilization. Detailed measurements and reporting also allow for instant, and in some cases, automatic, scaling up, and down based on dynamic need requirements. Resource flexibility is particularly useful when there are significant spikes, dips, or cyclical loads for infrastructure.

A few examples of current IaaS providers are Amazon Web Services, Microsoft Azure, and Google. They offer many different styles of compute, storage, and network, as well as many supporting solution services. They each offer several different economic models to match up to SLAs, OPEX and CAPEX requirements, risk and deployment options.

### SaaS - background
As many small and medium-sized organizations looked for additional ways to control cost, modernize strategy, and consume on-demand solutions, software licensing became a very complicated issue. An example of this is Oracle, a company that was a bit late to the cloud licensing game. New server configurations were much more substantial with more sockets, more cores, and more RAM. Even with no change in utilization or software configuration, Oracle client charges increased to over a million dollars due to new server sizing. This affected strategy, economics, and eventually technical decisions on how to move forward in the face of shattered budgets and ROI calculations.

Many organizations lack the skills or resources to create custom software applications. Freeware and opensource software helped some organizations, but they still required skills sets and significant adjustment for adoption. Software providers are starting looking for ways to offer online cloud-based solutions at lower cost and universal access. These new models would center around new licensing models tied to multiple users, a certain level of access, and SLAs rather than the size of the software infrastructure deployment.

With SaaS, the subscriber uses the provider's centralized application deployed using cloud infrastructure. SaaS enables access from any approved client device, browser, or custom interface. The user/subscriber does not have access to the underlying infrastructure, application code, or individual application attributes except for a set of named user-specific application configuration settings.

In the SaaS space, some applications have stabilized/normalized meaning they are widely adopted and have significant competition and innovation driving licensing costs downward, for example, office suites, collaboration software, and communications software. Software-as-a-Service providers offer a complete software application to customers using a license-based model that accesses the application on-demand via a self- service interface.

### SaaS - things to consider
Using SaaS, organizations have potentially limitless possibilities for running applications that may not have been otherwise possible given the limitations of their corporate systems, infrastructure, or resources. If the right middleware and associated components are deployed, SaaS can present massive incentives and benefits. Organizations can quickly realize benefits from scalability, flexibility, and on-demand self-service capabilities. Customer adoption accelerates as access to data and applications can be from virtually anywhere, at any time with internet access. Additional benefits include:
+ Cost control, cost reduction
+ Licensing or support becomes a built-in component for the provider and the subscriber benefits from economies of scale
+ The purchasing of up-front bulk licensing and the associated capital expenditure is removed and replaced by demand-based pay-as-you-go licensing models
+ User-based internal support requirements reduce significantly as the software cloud service provider can typically handle more of the support at scale
+ Ease of use and limited administration 
+ Automatic updates and patch management 
+ Improved security
+ Standardization and compatibility
+ Global accessibility

Notable providers of SaaS include Google, Microsoft, Oracle, Salesforce, and SAP.

### PaaS - background
PaaS takes both IaaS and SaaS and adds yet another twist on trying to solve the problem. As described earlier, people are trying to control costs, eliminate large major cash outlays, accelerate, modernize strategies, and move to only paying for what is needed, when it is needed. IaaS helped but still required a lot of people, skills, and money to support the applications. Based on our direct research, software required between 8x and 32x the annual cost of the server annually in management, maintenance, monitoring, and support. A $6,000 server written down over a 3-year use cycle would cost between $16,000 and $64,000 each year for software support. The cost was dependent on the specific software and organizational efficiency. These operational changes meant that new infrastructure and software models were required to keep businesses innovating and moving forward.

The next challenge was that the as-a-service model was not available with every software package. Some software was just not adaptable to modern cloud models. A complicating issue was that, for most companies, only about 15%-20% of software was off-the-shelf. Most of it was custom developed, homegrown, and built for specific functions and purposes within each business. Nearly every company still had to develop proprietary applications, middleware, services, connectors, workflows, and more. Each of those projects required different programming languages with different frameworks and libraries. How can things accelerate? How can costs be controlled?

Interestingly, people realized that the combinations of languages, libraries, and frameworks used were often the same or very similar. Consumers needed the ability to quickly build and deploy applications coded with provider-supported programming languages, services, libraries, and tools. The end user did not want to manage or control the underlying cloud infrastructure, but they did need to control the deployed application's configuration settings. CSPs responded by integrating all of the needed components and subsystems into a solution stack that could now be offered as a service or rented as-needed. This new PaaS enabled faster development at a lower cost. The environment was now ready to use, managed, and monitored, enabling developers to be productive immediately using the latest components available. This has led to many other variations where raw materials are integrated into environments that enable the building and assembling of new creations quickly and cost-effectively.

### PaaS - things to consider
Cloud PaaS has revolutionized software development and the means through which it is delivered to customers and users. Market entry barriers have been reduced dramatically by lower cost, accelerating time to market, and promoting innovative cultures within many organizations.

As PaaS providers are considered, the languages and frameworks supported are key. A provider that supports multiple relevant languages and frameworks can help avoid productivity pitfalls later. Developers need to write code in their preferred language that meets specified design requirements. Recent advances include options for open source development stacks and many new infrastructure deployment styles including OpenStack infrastructure, various containerization engines, and serverless (FaaS) options. PaaS providers that support multiple languages and deployment options reduce vendor lock-in and interoperability issues as applications grow and deployment locations change.

Applications are never static. They are continually changing, updating, and growing. Being able to deploy and move the application across different hosting environments is also a key PaaS benefit. Supporting multiple hosting environments helps the developer or administrator easily migrate the application if required. With this option, PaaS can also be used for contingency operations and business continuity to ensure continued availability. It is important to consider the final environment as platforms used by early users to test for functionality. These environments transition to a run environment at some point. The final environment may not be the same as originally intended as many things change throughout the process and testing. Multiple deployment options are an important consideration when picking a platform provider.

Many platform providers started with the idea of adding value by assembling platforms. Make the platform proprietary with their unique workflows, combinations, components and create a sort of lock-in mentality. Providers wanted clients to use only their specific platform and direction. The goal was to make things very sticky with limited ability to transition between provider platforms. Recent changes have added much-needed flexibility matching developer needs and requirements. To stay relevant, platform providers needed to respond or lose the developers and their communities to more flexible environments and open source options.

The application programming interfaces (APIs) are required for nearly every form of software in our space today with RESTful being elevated to the de-facto standard in most cases. A service provider always offers specified APIs or integration. Developers could run their application in various environments based on common and standard API structures. This ensured consistency and quality for customers and users. PaaS pushed forward infrastructure concepts like auto-scaling where software could now take the responsibility of scale up and scale down and manipulating the infrastructure through APIs, as needed. This would help accommodate cyclical, less predictable demand patterns, seasonal business, and event-driven activities. Mother's Day would bring down Hallmark's online card servers every year until they were able to implement auto-scaling. Before auto-scaling, Hallmark would have to build and engineer infrastructure for a guesstimated utilization level. With auto-scaling, the platform allocates resources and assigns them these applications, as required. This capability is a key driver for any seasonal organizations that experience spikes and drops in usage.

When thinking through platform providers, look for flexibility and future migration options. Look for the right combinations of services and support with expertise in areas relevant to project needs and direction. Look for providers that not only provide the platform but also offer the other versions of the cloud as well. Where your project starts is not where it stays. Plan to move and change. It may not change often, but change happens. Plan for it up front.

Notable PaaS providers include Microsoft, Lightning, and Google.

### Other cloud service models
You have probably heard of many other X-as-a-Service offerings such as Storage-as-a- Service, Desktop-as-a-Service, Network-as-a-Service, Backend-as-a-Service, Function-as-a- Service. These other models are merely subsets or aggregations of SaaS, IaaS, or PaaS. Categorizing them into the three standard models simplifies any cloud conversation you may have.

#### Cloud deployment models
We have discussed the three standard cloud service models. The service model defines the what. What is unique about each model? What are they trying to solve? What are their strengths and weaknesses? Each of the discussed service models adheres to the five characteristics mentioned, possibly adhering in different ways. Within each of the service models, there may also be multiple ways to enable and deploy the service. The service model is the what, the deployment model is the how.

Many cloud services are straightforward to comprehend. For example, network as mentioned earlier. Most do not realize that the network was one of the very first types of IaaS, therefore, one of the original types of cloud. True, there are many types of services, and with that, an even greater number of ways to refer to them. In this section, we introduce the deployment models and some of the jargon. The discussion also addresses how the different deployment types are referenced, marketing names, labels, and currently used buzz words.

This section also demystifies some of the marketing hype which makes it easier to quiet the noise when participating in the often jargon-filled conversations. How is this bare metal different to a dedicated cloud? What is a public cloud? What is a private cloud and how is private different to dedicated? Is it different? Is private on-premises still considered as the cloud? Is a private cloud from a service provider also the cloud? If it is called a cloud, it must be a cloud?

#### Public
Public is the typical IaaS-compute deployment model most people think of when referring to the cloud. A public cloud service provider offers IT resources as-a-service and, as part of the service, is responsible for building, monitoring, and maintaining physical data centers and IT resources that are for dynamic public consumption. This IT service environment is shared among many customers which normally reduces costs for each customer. By leveraging economies of scale, the CSP enables higher average utilization of resources through the extensive use of virtualization, workload binding, offsetting clients workload patterns, and performance tiers.

The general public uses a public cloud infrastructure. The infrastructure may be owned, managed, and operated by a business, academic, or government organization, or some combination. The infrastructure is always on service provider premises as they have taken ownership of operations and maintenance. Amazon is a good example. The business started off by selling books. It then started to sell excess server and storage capacity to the general public. The infrastructure remained on-premise at Amazon locations.

A public cloud can fall into two sub-types within IaaS, self managed or fully managed. Both of these sub-types are discussed in greater detail later in this chapter. A public cloud is highly scalable, immediately deployed, portal driven, and can be parked or turned off when not in use.

Public cloud benefits include:
+ Ease of use and inexpensive setup, low cost of entry to the cloud 
+ Streamlined and easy-to-provision resources via a self-serve portal 
+ Scaled to meet customer needs
+ No wasted resources because customers pay only for what they consume 
+ Basic security services included

Public cloud considerations are:
+ How are noisy neighbors handled?
+ Does security line up with my requirements?
+ Is there any network access or storage limitations?
+ Cost of access or data transfer in/out?
+ Portability? Grow into other instance types and service types? What other services connect to it?
+ What is the price/performance metric?

Providers often mentioned in this space include Amazon, Microsoft, and Google, among others.

#### Private and dedicated
There are a lot of marketing, jargon and buzz words that come along with the cloud. Companies are fighting hard to create separation from the pack. Sounding unique and different was one way to try and differentiate. What is the difference between a dedicated and a private cloud? What is a virtual private cloud? Is a virtual private cloud different to a private cloud? Do these different versions adhere to the five characteristics of the cloud? Many factors drive interest in single-tenant infrastructure. Dedicated and private both, by definition, are single-tenant environments with the infrastructure only accessible by a single company or client. The difference ultimately comes down to economic model and access.

##### Private C=cloud
A private cloud is typically an on-client premise solution with the infrastructure leased or purchased by the company/entity using it. These environments can also be deployed within a service provider data center utilizing collocation services. This would still be considered an on-premises solution as the collocation space is just another leased location for theinfrastructure owner. A private cloud is typically managed by the organization it serves; however, outsourcing the general management of this to trusted third parties may also be an option. A private cloud is typically available only to the entity or organization, its employees, contractors, and selected third parties. The private cloud is also sometimes referred to as the internal or organizational cloud.

The factors driving the use of infrastructure may include legal limitations, trust, and security regulations. Private cloud benefits include more control over data, the underlying systems, and applications, ownership, retention of governance controls; and assurance over data location. Private clouds are typically more popular among large, complex organizations that have legacy systems and heavily customized environments. Additionally, where significant technology investment has been made, it may be more financially viable to utilize and incorporate these investments within a private cloud environment than to discard or retire such devices.

Is a private cloud really a cloud? It has cloud in the name. Having cloud in the name was not one of the five characteristics of the cloud. It is interesting to debate, you decide. Compare a private cloud to the five characteristics and come up with an answer.

##### Dedicated cloud
A dedicated cloud is very similar to a private cloud. It is also a single-tenant solution. Ownership and access differ. In a dedicated cloud, ownership of the infrastructure shifts to the service provider. The infrastructure is housed within the provider's data center. A dedicated environment is for use by the single tenant. Network, compute, and storage are dedicated to the single tenant.

The economic model for dedicated solutions is usually a combination of non-recurring cost (NRC) which is a one time fee up front, and monthly recurring cost (MRC), which is a monthly payment paid over a term (number of months or years). Dedicated solutions enable a shift from all capital upfront models (CAPEX) to smaller payments over a longer period (OpEx). Management and operations can continue to be in-house, outsourced, or a combination of both.

Is a dedicated cloud really a cloud service? It also has cloud in the name. This is also an interesting one to debate, you decide. Compare a private cloud to the five characteristics and come up with an answer for your conversations. When sorting out the answer, look at the economics. The cloud is an economic innovation. Ultimately, can you turn it off and give it back? Does billing stop? Do you stop paying for it when you shutdown?

##### Virtual private cloud
As with many things in our industry, the lines often get blurred (marketing may have something to do with it). Dedicated is an isolated environment deployed within the provider's data center. A virtual private cloud (VPC) is a variation of a dedicated cloud. A virtual private cloud combines concepts from a public and a dedicated cloud. VPC takes the concept of shared infrastructure and the economies of scale for servers and storage then combines it with an isolated network.

The very high cost of a dedicated cloud and the network challenges of noisy neighbors in a public cloud led service providers to the virtual private approach. VPC is the blending of strengths while trying to control some of the weaknesses. The name drives the blurred line in this service. A private cloud is typically deployed on client-owned infrastructure as an on-client-premise solution. A VPC is deployed on the service provider-owned infrastructure. This service would be more appropriately named a virtual dedicated cloud. Some providers have changed the name to eliminate some of the confusion within their product and solution sets.

##### Comnunity
In a community cloud, an IT infrastructure is provisioned for use by a specified community of end users. The community participants are from organizations that have shared concerns and governance requirements. Typically, these requirements link to mission, security, policy, or regulatory compliance. It can be owned, managed, or operated by a community member, a third party, or a combination. Community clouds may exist on or off premises.

A community cloud provides most of the same benefits as a public cloud deployment while providing heightened levels of privacy, security, and regulatory compliance.

##### Hybrid
A hybrid cloud is any solution that combines a cloud model with any other cloud or non- cloud deployment model. Most organizations tend to gravitate to the hybrid models as no single model or deployment type matches up to the multiple applications and services needed to support a business. Many applications cannot migrate readily to new services. Application dependencies may introduce additional risk for migrated applications. There is rarely a situation where everything is forklift moved all at one time from current state to future state. Hybrid is the typical path to the cloud for currently deployed applications and infrastructure.

In a hybrid IT environment, private clouds, public clouds, community clouds, traditional data centers, and services from service providers can be integrated and interconnected. Applications and services can then be deployed to and consumed from the most appropriate combination of services and environments.

Key benefits of the hybrid model are retention of ownership and oversight for critical tasks, reuse of earlier technology investments, tighter control over critical business components and systems and more cost-effective options for non-critical business functions. Cloud bursting and disaster recovery options can also be enhanced by using hybrid cloud deployments.

The basic understanding of the cloud deployment models are shown here:

![logo](/_media/c14.png)

### Other delivery models
The cloud, and technology in general, has a notion of fashion to it. Some things are in vogue while others fade from favor quickly. As cloud conversations happen, it is vital to see ahead of the curve and keep in mind overall direction. For decades, a consistent direction has been to place more power in the hands of the end user/consumer. Our cell phones today have more compute power and run more applications than many desktop computers sold a few years ago. Think forward a bit to IoT. Significant compute power and data are at our fingertips. Connected cars are currently built with nearly 40 processors, almost 100 sensors sending out 25 GB of data per hour. Connected cars are described as rolling data centers.

As technology continues to innovate and progress at incredible speeds, it is essential to raise your awareness of immerging trends. It is also important to quickly distinguish tech fashion from tech innovation. Real innovation always has an economic driver that is sustainable. Starbucks coffee did not invent coffee. Starbucks was when the first-time coffee and culture became inseparable. The iPhone was not the first mobile device; however, it was the first time a mobile device connected many of the most important facets of our home, work, and play lives. The cloud was not the first deployment of virtualization. The cloud is the first innovation that has directly connected the concepts of technology, strategy, and economics forever changing the way we build, deploy and consume technology and services.

The shortlist here includes some very innovative ideas that build on and extend the core concepts of cloud computing. These are a few things to watch as they climb the two hills of innovation. More on that later in this book:
+ Grid computing: Distributed and parallel computing capability where a virtual computer is composed of a cluster of networked and loosely coupled individual computers which act in concert to perform very large tasks.
+ Fog computing: A distributed computing model that provides IT services closer to the fog client. Sources are near-end user edge devices. Fog computing can handle data at the network level, on smart devices, and the end-user client side instead of sending data to a remote location for processing.
+ Dew computing: Dew computing is positioned at the ground level for the cloud and fog computing. When compared to fog computing, which is designed to support IoT applications that are sensitive to network latency and require real- time and dynamic network reconfigurability, this variant pushes the computing applications, data, and low-level services to the end users and away from centralized virtual nodes.
+ Edge computing: Edge computing extends cloud computing by pushing the processing, applications, and data as far away from centralized resources as possible. Moving work to the edge also means that devices may not always be connected to the internet (that is, mobile, laptop, tablet). This means that processing would also need a high level of redundancy with content highly distributed.
+ IoT: IoT is connecting the physical world with the logical one. Sensing and processing technology are being placed where needed when needed. Cloud computing is rapidly morphing to help catch, process, and utilize the vast amount of data already being generated by IoT initiatives and projects.
+ AI, neural networks, and machine learning: These concepts have been pulled together because they are hard to separate and sometimes they are used interchangeably even though there are distinct differences. AI has been around for decades, it is not new. However, cloud computing has removed many of the barriers that were slowing innovation; 300 computers for one hour can process a staggering amount of data, connect it, correlate it, learn from it and apply it. Cloud computing innovation has truly helped this field leap forward recently.

## 云清洗
Cloud washing is a term used to refer to the often deceptive attempt to rebrand an existing product or service by associating the buzzword cloud with it. Within a financial construct, there is a parallel that describes the practice of inflating financial results for a company's cloud business by redefining existing services and products as cloud services. A typical example of this is referring to access to any application or service over the internet through a browser as cloud computing, just because you are receiving the service over the internet.

Another example is the traditional application service provider (ASP) model where a third party offers individuals, and companies access over the internet to applications and services that would normally have been located in their own personal or enterprise computers. This is often marketed as a SaaS, but there are many significant differences between the two models. ASP is a software delivery method with a revenue model that is disconnected from the software itself. At its core, these are single-instance, single-tenant legacy software deployments. The revenue model is like renting a server with an application installed on it. This approach failed in the marketplace because it lacks scalability for the vendor, too much customization is required, and there is a single customer for the instantiation. There is also no organic aggregation of data, and no network effect data available for collection and aggregation.

SaaS, on the other hand, is an all-inclusive business architecture that is a value delivery method. Its built-in multi-tenancy design allows for shared resources and shared infrastructure. SaaS is scalable and offers true economies of scale to the service provider. This approach reduces overall costs, operational complexities, and customization. Multi- tenancy can also be leveraged to improve customer service and retention, reduce sales cycles, accelerate revenue, gain competitive advantage, and even directly monetize additional services.

Managed service arrangements are also sometimes referred to as cloud hosting. The difference here is that the day-to-day functions are outsourced to a particular vendor to realize an increase in efficiency around processes associated with data center operations. When doing this, the client also pays for all the capital investment (either up front or embedded in the recurring fee) and commits to regular payments over a minimum term. These payments are not driven by use but are a calculation related to total operational and customization costs over the minimum term, financial interest rates and a minimum profit for the service provider. In all cloud service models, the cloud service provider bears all capital cost and offers the same standard service to all marketplace customer. Payment is related directly to actual customer use, and there is no minimum term commitment.

## 云计算分类法
The cloud computing taxonomy was initially developed by the United States National Institute of Standards and Technology (NIST) as a tool for standardizing conversations around cloud architectures. Since then, this basic model has been enhanced by the community and broadly adopted to discuss basic concepts. The major taxonomy components are described here:
![logo](/_media/c15.png)

The service consumer is the entity (enterprise or end user) that actually uses the cloud service. Users will normally have multiple programming interfaces. These interfaces present themselves like any normal application and the user does not need to understand any cloud computing platform details. User interfaces can also provide administrative functions like virtual machine or storage management.

The cloud service provider (CSP) creates, manages, and delivers information technology services to the service consumer. Provider tasks vary based on the service model:
+ For SaaS, the provider installs, manages, and maintains all software. Service consumers only have access to the application.
+ For PaaS, the provider manages and provides a standardized application development environment. This is typically in the form of a development language framework.
+ For IaaS, the provider maintains and operates the facilities, hardware, virtual machines, storage, and network associated with the delivery of any information technology service. The service consumer, however, is responsible for service design, operations, and delivery.

Critical to the service provider's operations is the management layer. This layer meters and monitors the use of all services. It also provisions and deprovisions services based on user demand and service provider capacity. Management also includes billing, capacity planning, SLA management, and reporting. Security is applied across all aspects of the service provider's operations.

The service developer creates, publishes, and monitors cloud services. Typically, these consist of line-of-business applications delivered directly to end users. During service creation, analytics is used for remote debugging and service testing. When the service is published, analytics is also used to monitor service performance.

Standards and taxonomies will affect cloud use case scenarios in four different ways:
+ Within each type of cloud service
+ Across the different types of cloud services 
+ Between the enterprise and the cloud 
+ Within the private cloud of an enterprise

Within each type of cloud service (IaaS, PaaS, or SaaS), open standards help organizations avoid vendor lock-in by giving users the freedom to move to other cloud service providers without major application or operational modifications. Standards within an enterprise are normally driven by interoperability, auditability, security, and management requirements.

## 总结
As you move forward in cloud conversations, please keep in mind the five characteristics of the cloud. These characteristics will help you stay focused on aligning technology, economics, and strategy. The cloud's big innovation was economic, not technical. Strategy changing economics are driving rapid transformation and digitization. There are many different services, different economic and deployment models along with many different strategies to use them. The cloud is another tool in the toolbox. It is not the answer for everything, but it is quickly becoming the foundation for everything.

The next chapter starts the conversation on governance and change management. You may think that a cloud solutions architect's success depends on the technology chosen. That thinking couldn't be further from the truth. While cloud computing is foundational to digital transformation, successful cloud computing solutions must be built on top of an effective change management and IT governance foundation.