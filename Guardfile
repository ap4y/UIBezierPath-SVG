# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :ocunit,
      :test_paths    => ['Tests'],
      :derived_data  => '/tmp/tests',
      :workspace     => 'Tests/UIBezierPath_SVG.xcworkspace',
      :scheme        => 'UnitTests',
      :notification  => false,
      :test_bundle   => 'UIBezierPath_SVGTests' do

  watch(%r{^Tests/UIBezierPath_SVGTests/.+Tests\.m})
  watch(%r{^UIBezierPath\+SVG.[h,m]}) { |m| "Tests/UIBezierPath_SVGTests/UIBezierPath_SVGTests.m" }
end
