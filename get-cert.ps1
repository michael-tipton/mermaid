function Get-SSLCertificatePem([string]$Hostname, [string]$FilePath) {
    try {
        # Establish a TCP connection and get the SSL stream
        $tcpClient = New-Object System.Net.Sockets.TcpClient($Hostname, 443)
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, {
            param($sender, $certificate, $chain, $sslPolicyErrors)
            # Accept all certificates for retrieval purposes, handle errors later if needed
            return $true
        })

        # Perform the SSL handshake
        $sslStream.AuthenticateAsClient($Hostname)

        # Get the X509 certificate object
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)

        # Export the certificate as raw data (DER format bytes)
        $certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)

        # Convert the bytes to a Base64 string
        $base64Cert = [System.Convert]::ToBase64String($certBytes)

        # Add PEM headers and footers and format with line breaks
        $pemContent = "-----BEGIN CERTIFICATE-----`r`n"
        # The line below ensures proper formatting for PEM files
        $pemContent += ($base64Cert -replace '(.{64})', '$1`r`n')
        $pemContent += "`r`n-----END CERTIFICATE-----`r`n"

        # Save the content to the specified file path with ASCII encoding
        Set-Content -Path $FilePath -Value $pemContent -Encoding ASCII

        Write-Host "Successfully saved certificate to $FilePath" -ForegroundColor Green

        # Clean up the streams
        $sslStream.Close()
        $tcpClient.Close()

    } catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
}

# --- Example Usage ---
# Use an IP address or a domain name
$Target = "google.com" 
$OutputPath = "C:\Temp\google_cert.pem" # Ensure C:\Temp directory exists or change path

Get-SSLCertificatePem -Hostname $Target -FilePath $OutputPath










powershell -Command "$tcp = New-Object Net.Sockets.TcpClient('google.com', 443); $stream = $tcp.GetStream(); $sslStream = New-Object Net.Security.SslStream($stream); $sslStream.AuthenticateAsClient('google.com'); $cert = New-Object Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate); $bytes = $cert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert); $base64 = [Convert]::ToBase64String($bytes); $pem = '-----BEGIN CERTIFICATE-----`r`n' + ($base64 -replace '(.{64})', '$1`r`n') + '`r`n-----END CERTIFICATE-----`r`n'; Set-Content -Path C:\Temp\output.pem -Value $pem -Encoding Ascii; $sslStream.Close(); $tcp.Close(); Write-Host 'Certificate saved to C:\Temp\output.pem'"
