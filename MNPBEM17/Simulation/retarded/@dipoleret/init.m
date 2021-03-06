function obj = init( obj, varargin )
%  INIT - Initialize dipole moments.
%
%  Usage for obj = dipoleret :
%    obj = init( obj )
%      set dipole moments eye( 3 ) at all positions
%    obj = init( obj, dip, 'full' )
%      set user-defined dipole moments

%  Usage for obj = dipoleret :
%    obj = init( obj )
%      set dipole moments eye( 3 ) at all positions
%    obj = init( obj, dip )
%      set dipole moments dip at all positions
%    obj = init( obj, dip, 'full' )
%      set user-defined dipole moments

if isempty( varargin ) || ~isnumeric( varargin{ 1 } )
  %  default values for dipole orientations
  dip = eye( 3 );
elseif isnumeric( varargin{ 1 } )
  %  extract input
  [ dip, varargin ] = deal( varargin{ 1 }, varargin( 2 : end ) );
  %  'full' keyword set ?
  if ~isempty( varargin ) && ischar( varargin{ 1 } ) && strcmp( varargin{ 1 }, 'full' )
    [ key, varargin ] = deal( 'full', varargin( 2 : end ) );
  end
end
%  save options
obj.varargin = varargin;

%  dipole moments given at all positions
if exist( 'key', 'var' ) && strcmp( key, 'full' )
  if length( size( dip ) ) == 2
    dip = reshape( dip, [ size( dip ), 1 ] );
  end
  obj.dip = dip;
%  same dipole moments for all positions    
else
  if ~exist( 'dip', 'var' )
    dip = eye( 3 );
  end
  obj.dip = repmat( reshape( dip .', [ 1, fliplr( size( dip ) ) ] ),  ...
                                               [ obj.pt.n, 1, 1 ] );
end

%  get BEM options
op = getbemoptions( { 'dipole', 'dipoleret' }, varargin{ : } );
%  set medium
if isfield( op, 'medium' ) && ~isempty( op.medium )
  medium = op.medium;
else
  medium = 1;
end
%  set discretized surface of unit sphere
if isfield( op, 'pinfty' ) && ~isempty( op.pinfty )
  pinfty = op.pinfty;
else
  pinfty = trisphere( 256, 2 );
end
%  set up spectrum for calculation of radiative decay rate
obj.spec = spectrumret( pinfty, 'medium', medium );
