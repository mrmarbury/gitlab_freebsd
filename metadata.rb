name 'gitlab_freebsd'
maintainer 'Stefan Wendler'
maintainer_email 'stefan@binarysun.de'
license 'apachev2'
description 'Installs/Configures gitlab_freebsd'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.8'
issues_url 'https://github.com/<insert_org_here>/gitlab_freebsd/issues' if respond_to?(:issues_url)
source_url 'https://github.com/<insert_org_here>/gitlab_freebsd' if respond_to?(:source_url)

supports 'freebsd', '>=10.3'
