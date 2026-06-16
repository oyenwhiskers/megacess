Add-Type -AssemblyName System.Drawing

# Create bitmap
$bitmap = New-Object System.Drawing.Bitmap(1024, 1024)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Set high quality
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Create green brush for background
$greenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(67, 196, 99))

# Fill circle background
$graphics.FillEllipse($greenBrush, 20, 20, 984, 984)

# Create white brush for text
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

# Create font
$font = New-Object System.Drawing.Font("Arial", 600, [System.Drawing.FontStyle]::Bold)

# Create string format for centering
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center

# Draw "M" in center
$rect = New-Object System.Drawing.Rectangle(0, 0, 1024, 1024)
$graphics.DrawString("M", $font, $whiteBrush, $rect, $format)

# Save as PNG
$bitmap.Save("assets\images\app_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Cleanup
$graphics.Dispose()
$bitmap.Dispose()
$greenBrush.Dispose()
$whiteBrush.Dispose()
$font.Dispose()

Write-Host "✅ App icon created successfully at assets\images\app_icon.png"