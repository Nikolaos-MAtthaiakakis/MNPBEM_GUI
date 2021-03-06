function field = farfield( obj, spec, enei )
%  FARFIELD - Electromagnetic fields of dipoles in the far-field limit.
%    
%  Usage for obj = dipoleret :
%    field = farfield( obj, spec, enei )
%  Input
%    spec   :  SPECTRUMRET object 
%    enei   :  wavelength of light in vacuum
%  Output
%    field  :  compstruct object that holds far-fields

%  normal vectors of unit sphere at infinity
dir = spec.pinfty.nvec;
%  table of dielectric functions
epstab = obj.pt.eps;
%  wavenumber of light in medium
[ eps, k ] = epstab{ spec.medium }( enei );
%  refractive index
nb = sqrt( eps );

%  dipole points
pt = obj.pt;
%  dipole orientations
dip = obj.dip;

%%  far fields
%  make compstruct object
try
  field = compstruct(  ...
    comparticle( epstab, { spec.pinfty }, spec.medium ), enei );
catch
  field = compstruct( spec.pinfty, enei );
end

n1 = size( dir, 1 );
n2 = size( dip, 1 );
n3 = size( dip, 3 );

%  far fields
field.e = zeros( n1, 3, n2, n3 );
field.h = zeros( n1, 3, n2, n3 );
%  find dipoles that are connected through medium
ind = pt.index( find( pt.inout == spec.medium )' );

if ~isempty( ind )
  %  Green function for k r -> oo
  g = exp( - 1i * k * matmul( dir, permute( pt.pos, [ 2, 1, 3 ] ) ) );
  g = repmat( reshape( g, [ n1, 1, n2, 1 ] ), [ 1, 3, 1, n3 ] );
  %  reshape direction and dipole orientation
  dir = repmat( reshape( dir,    [ n1, 3, 1, 1 ] ), [ 1, 1, n2, n3 ] );
  dip = repmat( reshape(  ...
    permute( dip, [ 2, 1, 3 ] ), [ 1, 3, n2, n3 ] ), [ n1, 1, 1, 1 ] );
  %  far-field amplitude
  h = cross( dir, dip, 2 ) .* g;
  e = cross(   h, dir, 2 );
  field.e( :, :, ind, : ) = k ^ 2 * e( :, :, ind, : ) / eps;
  field.h( :, :, ind, : ) = k ^ 2 * h( :, :, ind, : ) / nb;
end
