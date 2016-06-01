case Facter.value('kernel')
when 'FreeBSD'
  knotc_bin = '/usr/sbin/knotc'
else
  knotc_bin = '/usr/local/sbin/knotc'
end
if File.exists? knotc_bin
  knot_version = Facter::Util::Resolution.exec("#{knotc_bin} -V 2>&1").split()[2]
  Facter.add(:knot_version) do
    setcode do
      knot_version
    end
  end
  Facter.add(:knot_version_major) do
    setcode do
      knot_version.split('.')[0]
    end
  end
end
