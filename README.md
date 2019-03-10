## Inspiration

Imagining a future where much of our digital interaction - especially transfer of value - occurs on chain, what opportunities do smart contracts offer for innovative forms of governance? As I see it, we each engage in a social contract to adhere to two forms of governance: identity-based and location-based. Identity-based governance mechanisms are most often opt in, though smart contracts may enforce these more successfully. Location-based governance mechanisms depend on where our bodies are on the Earth: which jurisdiction we are in.

I wanted to build the logic to detect where an account owner was, and execute code dependent on that. The applications could be extensive: code executed based on where connected sensors are (say a container entering a port or exclusive economic zone); travelers contributing to the governments of their host countries even in informal transactions; people donating to local community groups as an optional "opt-in" contract on top of their wallet contracts.

## What it does

The MVP implementation of the dapp detects the account owner's location (using their browser - though I'm looking forward to the FOAM dynamic proof of location protocol to provide a more secure and irrefutable location service) and automatically sends a small additional payment to contracts controlled by their containing jurisdiction, if they've opted in. Of course, sending funds is just the tip of the iceberg: any contract code could be executed with location (and time) as a condition.

## How I built it

I came to ETHParis to write a spatial abstraction library in Solidity, translating a library like Turf.js (which I used heavily in this project), or the spatial functions available in PySAL or the PostGIS extension of PostgreSQL. These are common algorithms, but I haven't seen them implemented in Ethereum, most likely because they are computationally intensive, rely on geometric functions like sine and cosine, and most usually can be solved with testing if a point is within a bounding box.

After translating several of the most commonly used functions from the Turf library, I decided to demonstrate the library through a use case. This centered on my goal to implement the `pointInPolygon` algorithm in Solidity - see [Tom Macwright's excellent Observable notebook](https://observablehq.com/@tmcw/understanding-point-in-polygon) explaining [James Halliday's original github post](https://github.com/substack/point-in-polygon). Based on this function I created a set of interacting contracts to demonstrate the functionality.

Jurisdictions control instances of a Jurisdiction contract - I imagined a jurisdiction to be a municipality, but any geographic entity could participate - and define their boundaries and "tax rate". People control instances of the LocationAware contract, which is holds funds and applies conditions to any transaction before they are transmitted to the intended recipient. LocationAware contract owners can "subscribe" to Jurisdiction contracts, opting in to have their location tested to see if they are within a jurisdiction when they send the transaction. If so, the recipient receives their value transfer and the Jurisdiction contract is sent an additional proportion, based on their tax rate.

## Challenges I ran into

First off, the fact that the EVM doesn't handle float values added a fair bit of confusion, even if theoretically the functions are (mostly the same). Writing helper functions to convert degrees to nanoradians in the spatial abstraction library, for example, was tricky - I tried to commit to scaling everything by 10**9, but it was difficult to keep track of.

Further, basic math functions like square root, sine and cosine are not native to solidity like the Math object is in Javascript. I found some really good resources - [Richard Horrocks' implementation of the Bablylonian method for finding square roots](https://ethereum.stackexchange.com/questions/2910/can-i-square-root-in-solidity) and [Sikorka's trigonometry library](https://github.com/Sikorkaio/sikorka/blob/master/contracts/trigonometry.sol), though found other functions missing - atan, for example, required to calculate the compass bearing from one point to another. Calculating distance on the earth's surface turned out to elude me as the Haversine formula is pretty heavy. A blessing, maybe, because this stumbling block inspired me to shift into building the demo now deployed on the Ropsten testnet.

Another major stumbling block for me (this is my first real independent Solidity program) was how tricky dealing with dynamic arrays are in Solidity. I ended up deciding to use a standard format for a 1-dimensional array of `int`s to represent the [lon,lat] coordinates that form boundary vertices, but not after a while bashing around with trying to access `int[2][]` arrays from another contract address.

## Accomplishments that I'm proud of

That I got it running, and deployed on the testnet, ready for presentation tomorrow feels great. The `pointInPolygon` algorithm is pretty cool, even if it is a direct translation from the substack implementation.

## What I learned

Prep - do more research and practice before the hackathon.

As my friend Yakko said : "There's no point in using truffle from the get go. Only to look cool. You try to compile. Fails. Remix tells you everything straight up. It's a very good tool." The challenges of developing in Remix (a few crashes, tiny UI, bright lights in my eyes) were so far outweighed by the instant feedback I got on bugs - really good for learning how the language works.

Spatial functions on the EVM are possible.

## What's next for Location Aware Wallet Contract

In 2019, faith in government seems to be at a bit of a low. I wrote this imagining a time (hopefully not too far off) when A: blockchains and smart contracts serve as our governments' digital / informational architecture and B: we have evolved a new, more participatory attitude towards civic engagement and our responsibility to contribute meaningfully through actions and resources to the public good. In this world, opting into additional taxation might be seen as a privilege enjoyed by those who know they have enough. I see the identity-based mechanisms as pretty simple - I'm from Colorado, I opt in to pay sales tax in Colorado on everything I buy, even if it is from a street vendor in Thailand. The location-aware system is a bit trickier.

Next is extending these concepts in my dissertation, applied to use cases where the cost of computationally-intensive algorithms might be justified: high value goods transiting the global supply chain, in the custodian of uncoordinated (or loosely coordinated) actors. I'm especially interested in applications in arms and export controls, and pharmaceuticals, and in enrolling governments to create policies that use distributed ledgers and smart contracts to better govern ourselves.
