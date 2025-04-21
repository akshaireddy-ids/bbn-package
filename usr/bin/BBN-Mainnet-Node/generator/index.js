import fs from "fs";
import util from "ethereumjs-util";
import randomstring from "randomstring";
import rimraf from "rimraf";

function createNodeKey(kind, index) {
  const basePath = `/${kind}s/${index}`;
  console.log(`Generating path ${kind}`);
  if (kind === 'writers' && fs.existsSync(basePath)) {
    console.log(`${kind}${index} already exists`);
    return;
  }
  
  fs.mkdirSync(`${basePath}/keys`, { recursive: true });
  fs.mkdirSync(`${basePath}/data`, { recursive: true });
  
  const privateKey = randomstring.generate({ length: 64, charset: 'hex' });
  const publicKey = util.privateToPublic(Buffer.from(privateKey, 'hex')).toString('hex');
  
  fs.writeFileSync(`${basePath}/keys/key`, privateKey);
  fs.writeFileSync(`${basePath}/keys/key.pub`, publicKey);
  
  console.log(`Generating ${kind}`);
}

const { VALIDATORS, WRITERS } = process.env;

rimraf.sync('/validators/*');
rimraf.sync('/writers/*');

for (let i = 1; i <= VALIDATORS; i++) {
  createNodeKey('validator', i);
}

for (let i = 1; i <= WRITERS; i++) {
  createNodeKey('writer', i);
}
