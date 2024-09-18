const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const app = express();
app.use(express.json());

const SECRET_KEY = "BCT_IA";
const users = [];
const PORT = 3000;

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) return res.sendStatus(401);

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

let sharedCounter = 0;
const lock = { isLocked: false };

const raceConditionSafe = () => {
  if (lock.isLocked) {
    return "Resource is locked!";
  }
  lock.isLocked = true;
  let temp = sharedCounter;
  temp++;
  sharedCounter = temp;
  setTimeout(() => {
    lock.isLocked = false;
  }, 5000);
  return sharedCounter;
};

const raceConditionUnsafe = () => {
  let temp = sharedCounter;
  temp++;
  setTimeout(() => {
    sharedCounter = temp;
  }, 5000);
  return temp;
};

app.get("/no-auth", (req, res) => {
  res.json({
    message:
      "This is sensitive data that anyone can access, no authentication required!",
  });
});

app.get("/auth", authenticateToken, (req, res) => {
  res.json({
    message: `Hello ${req.user.name}, you are authenticated!`,
    data: "Sensitive Data",
  });
});

app.get("/safe-race-condition", (req, res) => {
  const result = raceConditionSafe();
  res.json({ message: "Safe operation result", counter: result });
});

app.get("/unsafe-race-condition", (req, res) => {
  const result = raceConditionUnsafe();
  res.json({ message: "Unsafe operation result", counter: result });
});

app.post("/login", async (req, res) => {
  const { username, password } = req.body;
  const user = users.find((u) => u.username === username);
  if (!user) return res.status(400).json({ message: "User not found" });

  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return res.status(403).json({ message: "Invalid credentials" });

  const accessToken = jwt.sign({ name: user.username }, SECRET_KEY);
  res.json({ accessToken });
});

app.post("/register", async (req, res) => {
  const { username, password } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  users.push({ username, password: hashedPassword });
  res.status(201).json({ message: "User registered successfully!" });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
