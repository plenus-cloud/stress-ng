FROM debian:buster as builder

# intall gcc and supporting packages
RUN apt-get update && apt-get install -yq make gcc wget

WORKDIR /code

# download stress-ng sources
ARG STRESS_NG_VERSION
ENV STRESS_NG_VERSION ${STRESS_NG_VERSION:-0.10.10}
ADD https://github.com/ColinIanKing/stress-ng/archive/V${STRESS_NG_VERSION}.tar.gz .
RUN tar -xf V${STRESS_NG_VERSION}.tar.gz && mv stress-ng-${STRESS_NG_VERSION} stress-ng

# make static version
WORKDIR /code/stress-ng
RUN STATIC=1 make

# download bash-static
RUN wget https://github.com/robxu9/bash-static/releases/download/5.1.004-1.2.2/bash-linux-x86_64 -O /code/bash -o /dev/null

# Final image
FROM busybox

COPY --from=builder /code/stress-ng/stress-ng /
COPY --from=builder /code/bash /bin/bash
RUN chmod 755 /bin/bash /stress-ng
