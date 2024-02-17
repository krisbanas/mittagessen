# Step 1: Prepare builder container
FROM node:20-alpine3.19 as builder
RUN apk update && apk add --no-cache make git
WORKDIR /build-directory

# Step 2: Resolve dependencies
COPY package.json package-lock.json /build-directory/
RUN cd /build-directory  \
    && npm set progress=false  \
    && npm install --force \
    && npm install @angular-devkit/build-angular@17.2.0 --force\
    && npm install @angular/cli@17 --force

# Step 3: Build project
COPY . /build-directory
RUN npm run build

# Step 4: Copy build artifacts to runtime container
FROM nginx:1.25.4-alpine

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /build-directory/dist /usr/share/nginx/html
