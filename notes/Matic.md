Deploy results, all units should be read in Matic and not ETH

# 1_initial_migration.js

Replacing 'Migrations'

---

> transaction hash: 0x8ba85130002bca40a8bdccc8effd34d7b99e50e8ce25a0f175ab81c840405271
> Blocks: 2 Seconds: 5
> contract address: 0xf5977d9932D82bdE400F4Fdd7F392587CdfE280a
> block number: 9542107
> block timestamp: 1611071851
> account: 0x4B11B9A1582E455c2C5368BEe0FF5d2F1dd4d28e
> balance: 0.32084658
> gas used: 270388 (0x42034)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.00540776 ETH

Pausing for 2 confirmations...

---

> confirmation number: 2 (block: 9542110)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.00540776 ETH

# 2_deploy_contracts.js

Deploying 'Trigonometry'

---

> transaction hash: 0xae91491b8b69ebf16764018f41e6ecc91d89afdb670c7399a6ccf9ec9e28141c
> Blocks: 2 Seconds: 4
> contract address: 0xEE3d2c8A6a899Fe39A1fab331D81a5c4E48673a4
> block number: 9542117
> block timestamp: 1611071871
> account: 0x4B11B9A1582E455c2C5368BEe0FF5d2F1dd4d28e
> balance: 0.30469644
> gas used: 764969 (0xbac29)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.01529938 ETH

Pausing for 2 confirmations...

---

> confirmation number: 2 (block: 9542120)

Linking

---

- Contract: Spatial <--> Library: Trigonometry (at address: 0xEE3d2c8A6a899Fe39A1fab331D81a5c4E48673a4)

Deploying 'Spatial'

---

> transaction hash: 0xf3144443ecb3abad2dcc952fe0c36a64867bed42e559e34a3a10daa8cfe40f55
> Blocks: 4 Seconds: 8
> contract address: 0xa131725253cF8c3920978bA9D5a3292DB0AC5b7b
> block number: 9542124
> block timestamp: 1611071885
> account: 0x4B11B9A1582E455c2C5368BEe0FF5d2F1dd4d28e
> balance: 0.25250868
> gas used: 2609388 (0x27d0ec)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.05218776 ETH

Pausing for 2 confirmations...

---

> confirmation number: 2 (block: 9542131)

Deploying 'Jurisdiction'

---

> transaction hash: 0xb40b283970a5aca5fbd159af97e59757910db16b47e1709aa7a5e825d207a486
> Blocks: 2 Seconds: 4
> contract address: 0x906DB5bfbF5103F0461dD985FFA9B4a77260d211
> block number: 9542135
> block timestamp: 1611071907
> account: 0x4B11B9A1582E455c2C5368BEe0FF5d2F1dd4d28e
> balance: 0.23702714
> gas used: 774077 (0xbcfbd)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.01548154 ETH

Pausing for 2 confirmations...

---

> confirmation number: 2 (block: 9542138)
> Juristiction Contract deployed at: 0x906DB5bfbF5103F0461dD985FFA9B4a77260d211

Linking

---

- Contract: LocationAware <--> Library: Spatial (at address: 0xa131725253cF8c3920978bA9D5a3292DB0AC5b7b)

Deploying 'LocationAware'

---

> transaction hash: 0xb31ef6fcb4cb5b4ca52207357e5b232d2a9c54e5b02f6ee37b54a6153ae01ae0
> Blocks: 2 Seconds: 4
> contract address: 0xC0edEFdDBC317c84230861A103Dcf75Ad6755C0e
> block number: 9542142
> block timestamp: 1611071921
> account: 0x4B11B9A1582E455c2C5368BEe0FF5d2F1dd4d28e
> balance: 0.21465038
> gas used: 1118838 (0x111276)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.02237676 ETH

Pausing for 2 confirmations...

---

> confirmation number: 1 (block: 9542144)
> confirmation number: 3 (block: 9542146)
> Location Aware Contract deployed at: 0xC0edEFdDBC317c84230861A103Dcf75Ad6755C0e

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.10534544 ETH

# Summary

> Total deployments: 5
> Final cost: 0.1107532 ETH
