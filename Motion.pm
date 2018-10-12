package Motion;

use strict;
use warnings;
use feature qw(say);

use LWP::UserAgent;
use HTTP::Request;
use JSON::XS;
use File::Slurp;
use Data::Dumper;


=head2

Motion->new(uri_base => '' , key => '', def_param => '');


=cut
sub new(@)
{
    my $this = shift;
    my %params = @_;

    my $self = {};
    $self->{uri} = $params{uri_base} || 'https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect';
    $self->{key} = $params{key} || die "Subscribtion key not specified!";
    $self->{def_param} = '?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise';
    
    bless($self, $this);
}


sub _make_req
{
    my $this = shift;
    
    my $req = HTTP::Request->new( POST =>  $this->{uri} . $this->{def_param});

    $req->header(
           'Accept'       => "application/json",
           'Content-type' => "application/octet-stream",
           'Ocp-Apim-Subscription-Key' => $this->{key},
           );

    $this->_make_ua;
    $this->{req} = $req;

    return $req;           
}


sub _make_ua
{
    my $this = shift;
    my $ua = LWP::UserAgent->new;
    $ua->ssl_opts( SSL_verify_mode => 0, verify_hostname => 0 );
    
    $this->{ua} = $ua;  

    return $ua;
}

=head2

get request to API with binary_file

=cut
sub get_request($)
{
    my $this = shift;
    my $binary_file = shift;
    
    die "Not file exists: $binary_file" unless -f $binary_file;
    
    my $binary_data = read_file( $binary_file, binmode => ':raw' ) ;
    # local for add_content in-place
    local $this->{req};

    my $req = $this->{req} ? $this->{req} : $this->_make_req();
    $this->{ua} = $this->{ua} ? $this->{ua} : $this->_make_ua;

    $req->add_content($binary_data);

    my $response = $this->{ua}->request($req);
    my $result = eval { JSON::XS->new->decode($response->content) };
    die "Error JSON decoded: $@" if $@;

    if($response->is_success)
    {
      #say Dumper $result;
      return $this->_parse_result($result);
    }
    else
    {
      return $result->{error}->{message};
    }
    
}


sub _parse_result
{
    my $this = shift;
    my $result = shift;

    my %FACES;

    if (ref($result) eq 'ARRAY')
    {
        for my $row(@$result)
        {
            for my $item(keys %$row)
            {
            #   say $row->{faceId} if $item eq 'faceId';
            #   say "$item: " . Dumper $row->{$item};
                if($item eq 'faceAttributes')
                {
                    # faceId as key
                    $FACES{$row->{faceId}} = 
                    {
                        age => $row->{faceAttributes}{gender},
                        gender => $row->{faceAttributes}{age},
                        glasses => $row->{faceAttributes}{glasses},
                        beard => $row->{faceAttributes}{beard},
                        moustache => $row->{faceAttributes}{moustache},
                        sideburns => $row->{faceAttributes}{sideburns}
                    }
                    
                }
            }
        }
    }
    else
    {
        for my $item(keys %$result)
        {
            say "$item: " . Dumper $result->{$item};
        }
    }

    return \%FACES;

}

1;

__END__

Author: P.Kuptsov
Version: 1.0
GIT: https://github.com/poizon/motion.git


