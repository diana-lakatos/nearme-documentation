class PopulateDomainLoadBalancerName < ActiveRecord::Migration

  def change
    domains.each do |load_balancer_name, domain_name|
      next if domain_name.nil?
      next if domain_name =~ /elb.amazonaws.com/

      update_domain domain_name, load_balancer_name
    end
  end

  private

  def domains
    [['wyprawisko-pl', 'wyprawisko.pl'],
     ['www-vegvisits-com', 'www.vegvisits.com'],
     ['www-theintelligencecommunity-com', 'www.theintelligencecommunity.com'],
     ['www-thecampaignexchange-com', 'www.thecampaignexchange.com'],
     ['www-theatregalleria-com', 'www.theatregalleria.com'],
     ['storageb2b', 'www.storageb2b.com'],
     ['www-slipaway-co', 'www.slipaway.co'],
     ['www-shareacamper-com-au', 'www.shareacamper.com.au'],
     ['www-shareacamper-co-nz', 'www.shareacamper.co.nz'],
     ['www-rentalist-co', 'www.rentalist.co'],
     ['www-rent-able-com', 'www.rent-able.com'],
     ['patme', 'www.patme.com'],
     ['www-mybioinformatics-com', 'www.mybioinformatics.com'],
     ['www-megananny-com', 'www.megananny.com'],
     ['www-makefastmooring-com', 'www.makefastmooring.com'],
     ['www-hobbyhire-com-au', 'www.hobbyhire.com.au'],
     ['www-froggler-com', 'www.froggler.com'],
     ['www-camagora-com', 'www.camagora.com'],
     ['www-bookafish-com', 'www.bookafish.com'],
     ['www-3space-org', 'www.3space.org'],
     ['test-shareshed-ca', 'test.shareshed.ca'],
     ['subcorps-com', 'subcorps.com'],
     ['storex-me', 'storex.me'],
     ['stokeshare', 'stokeshare.com'],
     ['spacer-com-au', 'spacer.com.au'],
     ['shareshed-ca', 'shareshed.ca'],
     ['sawdustandsod-com', 'sawdustandsod.com'],
     ['rvwithme', 'rvwithme-329705859.us-west-1.elb.amazonaws.com'],
     ['rvtripper-com', 'rvtripper.com'],
     ['rentalist-co', 'rentalist.co'],
     ['rent-able-com', 'rent-able.com'],
     ['plants-com', 'plants.com'],
     ['nuclearlink-net', 'nuclearlink.net'],
     ['military-borrowshare-com', 'military.borrowshare.com'],
     ['me2yourentals-com', 'me2yourentals.com'],
     ['gogetwet', 'gogetwet-1383042834.us-west-1.elb.amazonaws.com'],
     ['getgonetraveler-com', 'getgonetraveler.com'],
     ['farmbackup-dk', 'farmbackup.dk'],
     ['eetalent-com', 'eetalent.com'],
     ['book-a-fish-com', 'book-a-fish.com'],
     ['bikeroost-com', 'bikeroost.com'],
     ['bikeroost', 'bikeroost-270500441.us-west-1.elb.amazonaws.com'],
     ['99spaces-co', '99spaces.co'],
     ['staging', nil],
     ['www-two-sypper-com', nil],
     ['arteryasia-com', nil],
     ['ElectricAudio-com', nil],
     ['qa-3', nil],
     ['shareacamper-co-nz', nil],
     ['qa-2', nil],
     ['qa-eetalent', nil],
     ['qa-spacer', nil],
     ['qa-1', nil],
     ['sharequip-com', nil],
     ['near-me-com', nil],
     ['www-keytooffice-com', nil],
     ['production-assets', nil],
     ['staging-assets', nil],
     ['production', nil],
     ['production-oregon', nil],
     ['devmesh-orgeon', nil],
     ['assets-production', nil]
    ]
  end

  def update_domain(domain_name, load_balancer_name)
    Domain
      .find_by(name: domain_name)
      .update_attributes(load_balancer_name: load_balancer_name)
  end
end
