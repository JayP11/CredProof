CredProof – Decentralized Academic Credential Verification System

Developed a smart contract on Ethereum using Solidity to issue, store, and verify academic certificates. Implemented role-based access control with OpenZeppelin to allow only verified universities to issue credentials. Each certificate is uniquely hashed and linked to IPFS for tamper-proof storage and verification. Enabled public and permissionless verification via cryptographic proofs, while allowing students to access their full certificate history on-chain.

🛠 Tech Stack
Solidity (v0.8.20)

Foundry (for smart contract testing)

OpenZeppelin (AccessControl, Counters)

IPFS (for off-chain certificate storage)

📄 Features
🎓 Only authorized universities can issue certificates
🔐 Certificates are hashed and stored immutably on-chain
📁 IPFS links store actual certificate documents off-chain
🔎 Public certificate verification using on-chain hashes
🧑 Students can retrieve all certificates issued to them
🛡 Role-based access (Admin & University)

🧪 Testing
Unit tests are written using Foundry (forge-std) and cover:
✅ Only universities can issue certificates
📦 Certificate data storage and hash validation
🔎 On-chain certificate verification (positive and negative cases)
🧑‍🎓 Multiple certificates per student
👮 Admin-only university role management

Run Tests
bash
Copy
Edit
forge test
Example output:

scss
Copy
Edit
[PASS] testOnlyUniversityCanIssueCertificate() (gas: 136489)
[PASS] testVerifyCertificateSuccess() (gas: 34562)
[PASS] testOnlyAdminCanAddUniversity() (gas: 89213)
...

🔐 Roles
DEFAULT_ADMIN_ROLE: Can add/revoke universities

UNIVERSITY_ROLE: Can issue certificates

🧾 Sample Certificate Structure
solidity
Copy
Edit
struct Certificate {
    uint256 id;
    string studentName;
    address studentWallet;
    string courseName;
    string degree;
    uint256 issueDate;
    string ipfsHash;
    bytes32 dataHash;
}
📦 Folder Structure
bash
Copy
Edit
├── src/
│   └── Credentify.sol
├── test/
│   └── credentify.t.sol
├── foundry.toml
└── README.md
