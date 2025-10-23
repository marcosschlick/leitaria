import bcrypt from "bcrypt";

async function hashPassword(password) {
  return bcrypt.hash(password, 8);
}

async function checkPasswordHash(password, hashedPassword) {
  return bcrypt.compare(password, hashedPassword);
}

export { checkPasswordHash, hashPassword };
