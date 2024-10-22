FROM ubuntu:20.04

#input GitHub runner version argument

ARG RUNNER_VERSION=2.320.0

ENV DEBIAN_FRONTEND=noninteractive

LABEL BaseImage="ubuntu:20.04"

LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages + add a non-sudo user

RUN apt-get update -y && useradd -m docker

# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)

RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git azure-cli jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# cd into the user directory, download and unzip the github actions runner

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
&& curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
&& tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/start.sh
# Install OpenJDK 16
RUN apt-get install -y openjdk-16-jdk

# Verify Java installation
RUN java -version

# # Install Maven 3.9
 RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz && \
     tar xzvf apache-maven-3.9.5-bin.tar.gz && \
     mv apache-maven-3.9.5 /opt/maven && \
     ln -s /opt/maven/bin/mvn /usr/bin/mvn

# Set Maven environment variables
 ENV MAVEN_HOME /opt/maven
 ENV PATH $MAVEN_HOME/bin:$PATH

# Verify Maven installation
 RUN mvn -version

# Install JMeter
 RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.1.1.tgz && \
    tar xzvf apache-jmeter-5.1.1.tgz && \
     mv apache-jmeter-5.1.1 /opt/jmeter && \
     ln -s /opt/jmeter/bin/jmeter /usr/bin/jmeter
 COPY SampleAPI.jmx //home/runner/work/_temp/    
 ENV PATH /opt/jmeter/bin:$PATH

# #Verify JMeter installation
 RUN jmeter --version

 USER docker

# set the entrypoint to the start.sh script

ENTRYPOINT ["start.sh"]
CMD ["start.sh"]