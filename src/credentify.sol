// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DecentralizedCredentialSystem is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _certificateIds;

    bytes32 public constant UNIVERSITY_ROLE = keccak256("UNIVERSITY_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UNIVERSITY_ROLE, msg.sender); // Deployer is also a university initially
    }

    struct Certificate {
        uint256 id;
        string studentName;
        address studentWallet;
        string courseName;
        string degree;
        uint256 issueDate;
        string ipfsHash; // Link to certificate PDF
        bytes32 dataHash; // Hash of all fields (verifiable)
    }

    mapping(uint256 => Certificate) public certificates; // certId -> Certificate
    mapping(address => uint256[]) public studentToCertificates; // student -> list of cert IDs

    event CertificateIssued(
        uint256 indexed certId,
        address indexed student,
        string studentName,
        string courseName,
        string degree,
        uint256 issueDate,
        string ipfsHash
    );

    /// @notice Issue a new certificate to a student
    function issueCertificate(
        address studentWallet,
        string memory studentName,
        string memory courseName,
        string memory degree,
        string memory ipfsHash) public onlyRole(UNIVERSITY_ROLE) {
        _certificateIds.increment();
        uint256 newCertId = _certificateIds.current();

        bytes32 certHash = keccak256(
            abi.encodePacked(studentName, studentWallet, courseName, degree, ipfsHash)
        );

        certificates[newCertId] = Certificate(
            newCertId,
            studentName,
            studentWallet,
            courseName,
            degree,
            block.timestamp,
            ipfsHash,
            certHash
        );

        studentToCertificates[studentWallet].push(newCertId);

        emit CertificateIssued(
            newCertId,
            studentWallet,
            studentName,
            courseName,
            degree,
            block.timestamp,
            ipfsHash
        );
    }

    /// @notice Verify a certificate by its ID and fields
    function verifyCertificate(
        uint256 certId,
        string memory studentName,
        address studentWallet,
        string memory courseName,
        string memory degree,
        string memory ipfsHash
    ) public view returns (bool) {
        Certificate memory cert = certificates[certId];
        bytes32 inputHash = keccak256(
            abi.encodePacked(studentName, studentWallet, courseName, degree, ipfsHash)
        );
        return cert.dataHash == inputHash;
    }

    /// @notice Get all certificate IDs for a student
    function getStudentCertificateIds(address studentWallet) public view returns (uint256[] memory) {
        return studentToCertificates[studentWallet];
    }

    /// @notice Add another university
    function addUniversity(address universityAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(UNIVERSITY_ROLE, universityAddress);
    }

    /// @notice Revoke university access
    function revokeUniversity(address universityAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(UNIVERSITY_ROLE, universityAddress);
    }
}

function getCertificatesByStudent(address studentWallet) public view returns (Certificate[] memory) {
    uint256[] memory ids = studentToCertificates[studentWallet];
    Certificate[] memory result = new Certificate[](ids.length);

    for (uint256 i = 0; i < ids.length; i++) {
        result[i] = certificates[ids[i]];
    }

    return result;
}

