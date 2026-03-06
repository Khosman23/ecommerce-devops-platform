FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY . .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

USER node

CMD ["node", "index.js"]
```

**Why each line matters:**
- `node:20-alpine` — lightweight base image, smaller attack surface
- `npm ci` — clean install, faster and more reliable than `npm install` in CI
- `HEALTHCHECK` — Docker itself will monitor if the container is healthy
- `USER node` — never run as root inside a container, security best practice

---

### Step 4 — Create a .dockerignore

In `services/api-gateway/` create `.dockerignore`:
```
node_modules
npm-debug.log
.env
*.test.js