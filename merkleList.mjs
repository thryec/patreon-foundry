import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";

const whitelist = [
  "0x3eb9c5B92Cb655f2769b5718D33f72E23B807D24",
  "0x86c480486eB70482596091886b9D9c329c067958",
  "0x4C36B84b2974604e0fEA458198F30864a70481E0",
  "0xA73B9e90258cd779d3341D8f4eA2C793372F502a",
];

const leafNodes = whitelist.map((addr) => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sort: true });
const rootHash = merkleTree.getRoot();

console.log("root hash:", rootHash.toString("hex"));
console.log("merkle tree: \n ", merkleTree.toString());

const claimingAddress = leafNodes[0];
const goodProof = merkleTree.getHexProof(claimingAddress);
const goodValid = merkleTree.verify(goodProof, claimingAddress, rootHash);

// console.log('good proof: ', goodProof)
// console.log('good valid: ', goodValid)
