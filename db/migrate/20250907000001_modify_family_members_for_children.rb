class ModifyFamilyMembersForChildren < ActiveRecord::Migration[8.0]
  def up
    # Renombrar relationship a gender
    rename_column :family_members, :relationship, :gender
    
    # Cambiar el tipo de columna y actualizar valores existentes
    change_column :family_members, :gender, :string, limit: 20
    
    # Actualizar valores existentes a español
    execute <<-SQL
      UPDATE family_members 
      SET gender = CASE 
        WHEN gender IN ('son', 'brother') THEN 'masculino'
        WHEN gender IN ('daughter', 'sister') THEN 'femenino'
        ELSE 'masculino'
      END;
    SQL
    
    # Actualizar education_level a español
    execute <<-SQL
      UPDATE family_members 
      SET education_level = CASE 
        WHEN education_level = 'preschool' THEN 'preescolar'
        WHEN education_level = 'primary' THEN 'primaria'
        WHEN education_level = 'secondary' THEN 'secundaria'
        WHEN education_level = 'high_school' THEN 'bachillerato'
        WHEN education_level = 'technical' THEN 'tecnico'
        WHEN education_level = 'university' THEN 'universitario'
        WHEN education_level = 'graduate' THEN 'postgrado'
        ELSE 'preescolar'
      END;
    SQL
  end

  def down
    # Revertir education_level a inglés
    execute <<-SQL
      UPDATE family_members 
      SET education_level = CASE 
        WHEN education_level = 'preescolar' THEN 'preschool'
        WHEN education_level = 'primaria' THEN 'primary'
        WHEN education_level = 'secundaria' THEN 'secondary'
        WHEN education_level = 'bachillerato' THEN 'high_school'
        WHEN education_level = 'tecnico' THEN 'technical'
        WHEN education_level = 'universitario' THEN 'university'
        WHEN education_level = 'postgrado' THEN 'graduate'
        ELSE 'preschool'
      END;
    SQL
    
    # Revertir gender a relationship
    execute <<-SQL
      UPDATE family_members 
      SET gender = CASE 
        WHEN gender = 'masculino' THEN 'son'
        WHEN gender = 'femenino' THEN 'daughter'
        ELSE 'son'
      END;
    SQL
    
    rename_column :family_members, :gender, :relationship
  end
end

