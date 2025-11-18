#!/usr/bin/env ruby
# Script para generar PDF del manual de uso

require 'prawn'
require 'prawn/table'

# Suprimir warning sobre fuentes internacionales
Prawn::Fonts::AFM.hide_m17n_warning = true

# Leer el archivo Markdown
manual_content = File.read('MANUAL_DE_USO.md')

# Crear el PDF
Prawn::Document.generate('MANUAL_DE_USO.pdf', page_size: 'A4', margin: [50, 50, 50, 50]) do
  # Configuración de fuentes
  font_families.update(
    "DejaVu" => {
      normal: "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
      bold: "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
      italic: "/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf",
      bold_italic: "/usr/share/fonts/truetype/dejavu/DejaVuSans-BoldOblique.ttf"
    }
  )
  
  font "DejaVu"
  
  # Variables para el parsing
  lines = manual_content.split("\n")
  current_section = nil
  in_list = false
  list_items = []
  
  # Procesar cada línea
  lines.each_with_index do |line, index|
    # Saltar líneas vacías al inicio
    next if line.strip.empty? && index == 0
    
    # Título principal
    if line.start_with?('# Manual de Uso')
      move_down 20
      text "MANUAL DE USO DEL SISTEMA RAB", size: 24, style: :bold, align: :center
      move_down 10
      text "Reserva Activa Bolivariana - Panel Administrativo", size: 16, align: :center, color: "666666"
      move_down 30
      stroke_horizontal_rule
      move_down 20
      next
    end
    
    # Títulos de sección (##)
    if line.start_with?('## ') && !line.start_with?('###')
      start_new_page if cursor < 100
      move_down 20
      section_title = line.gsub(/^##\s+/, '').gsub(/📋|📞|📝/, '')
      text section_title, size: 18, style: :bold, color: "722F37"
      move_down 10
      stroke_horizontal_rule
      move_down 15
      next
    end
    
    # Subtítulos (###)
    if line.start_with?('### ')
      move_down 15
      subtitle = line.gsub(/^###\s+/, '').gsub(/⚠️|✅|📊|🏖️|🕒|📋|🔐|👨‍👩‍👧‍👦|🏠|👥/, '')
      text subtitle, size: 14, style: :bold
      move_down 8
      next
    end
    
    # Sub-subtítulos (####)
    if line.start_with?('#### ')
      move_down 10
      subsubtitle = line.gsub(/^####\s+/, '')
      text subsubtitle, size: 12, style: :bold
      move_down 5
      next
    end
    
    # Separadores (---)
    if line.strip == '---'
      move_down 10
      stroke_horizontal_rule
      move_down 10
      next
    end
    
    # Listas numeradas
    if line.match(/^\d+\.\s+/)
      item = line.gsub(/^\d+\.\s+/, '').gsub(/\[.*?\]\(.*?\)/, '') # Remover enlaces
      item = item.gsub(/\*\*(.*?)\*\*/, '\1') # Remover negritas de enlaces
      move_down 5
      text "• #{item}", size: 11, indent_paragraphs: 20
      next
    end
    
    # Listas con guiones
    if line.start_with?('- ') && !line.start_with?('- **')
      item = line.gsub(/^-\s+/, '').gsub(/✅|📊|🏖️|🕒|📋|🔐|👨‍👩‍👧‍👦|🏠|👥/, '')
      item = item.gsub(/\*\*(.*?)\*\*/, '\1')
      move_down 3
      text "• #{item}", size: 11, indent_paragraphs: 20
      next
    end
    
    # Listas con asteriscos
    if line.start_with?('* ')
      item = line.gsub(/^\*\s+/, '')
      move_down 3
      text "• #{item}", size: 11, indent_paragraphs: 20
      next
    end
    
    # Texto con negritas
    if line.include?('**')
      # Procesar negritas
      parts = line.split(/(\*\*.*?\*\*)/)
      parts.each do |part|
        if part.start_with?('**') && part.end_with?('**')
          text part.gsub(/\*\*/, ''), style: :bold, inline_format: true
        else
          text part unless part.empty?
        end
      end
      move_down 8
      next
    end
    
    # Texto normal
    unless line.strip.empty?
      # Limpiar emojis y caracteres especiales
      clean_line = line.gsub(/✅|📊|🏖️|🕒|📋|🔐|👨‍👩‍👧‍👦|🏠|👥|⚠️|📞|📝/, '')
      clean_line = clean_line.gsub(/`(.*?)`/, '\1') # Código inline
      clean_line = clean_line.gsub(/\[.*?\]\(.*?\)/, '') # Enlaces
      
      if clean_line.strip.length > 0
        move_down 5 if index > 0 && !lines[index-1].strip.empty?
        text clean_line, size: 11
      end
    else
      move_down 5
    end
  end
  
  # Número de página
  number_pages "Página <page> de <total>", {
    at: [bounds.right - 150, 0],
    width: 150,
    align: :right,
    size: 9,
    color: "666666"
  }
end

puts "✅ PDF generado exitosamente: MANUAL_DE_USO.pdf"

